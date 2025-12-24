-- ==========================================
-- COMPLETE scheduling + cut-sheet schema
-- Beef & Hog only; Whole/Half orders
-- Includes:
-- Customers, Orders, Generic CutSheets/CutItems,
-- DailySlots (+ view), and vendor-sheet-specific:
-- DonBeefCutSheets, DonPorkCutSheets
-- ==========================================

PRAGMA foreign_keys = ON;
BEGIN TRANSACTION;

-- =========================
-- Customers
-- =========================
CREATE TABLE IF NOT EXISTS Customers (
  CustomerId INTEGER PRIMARY KEY AUTOINCREMENT,
  FirstName TEXT NOT NULL,
  LastName TEXT NOT NULL,
  Phone TEXT,
  Email TEXT,
  Notes TEXT,
  CreatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- Orders (one per animal/portion instance)
-- =========================
CREATE TABLE IF NOT EXISTS Orders (
  OrderId INTEGER PRIMARY KEY AUTOINCREMENT,
  CustomerId INTEGER NOT NULL,
  Species TEXT NOT NULL CHECK (Species IN ('Beef','Hog')),
  Portion TEXT NOT NULL CHECK (Portion IN ('Whole','Half')),
  DropOffDate TEXT NOT NULL, -- YYYY-MM-DD
  SlotDate TEXT, -- YYYY-MM-DD (booked capacity day; define meaning in your workflow)
  SlotShop TEXT, -- optional: which shop the slot is for (e.g. 'Don' or 'McConnell')
  EstimatedWeight REAL, -- optional
  Notes TEXT, -- optional notes provided by customer
  Status TEXT NOT NULL DEFAULT 'Received',
  DueDate TEXT, -- YYYY-MM-DD optional
  CreatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UpdatedAt TEXT,
  FOREIGN KEY (CustomerId) REFERENCES Customers(CustomerId) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_orders_customer ON Orders(CustomerId);
CREATE INDEX IF NOT EXISTS idx_orders_dropoff ON Orders(DropOffDate);
CREATE INDEX IF NOT EXISTS idx_orders_slotdate ON Orders(SlotDate);
CREATE INDEX IF NOT EXISTS idx_orders_status ON Orders(Status);

-- ==========================================================
-- CutSheet State (NEW)
-- Universal status tracking for ALL cut sheets (Don/McConnell)
-- Allows: Draft vs Finalized, UpdatedAt, FinalizedAt, FinalizedBy
-- Keeps vendor-specific tables unchanged and scalable.
-- ==========================================================
CREATE TABLE IF NOT EXISTS CutSheetState (
  OrderId INTEGER PRIMARY KEY,
  Status TEXT NOT NULL CHECK (Status IN ('Draft','Finalized')) DEFAULT 'Draft',
  UpdatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FinalizedAt TEXT,
  FinalizedBy TEXT,
  FOREIGN KEY (OrderId) REFERENCES Orders(OrderId) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_cutsheetstate_status ON CutSheetState(Status);
CREATE INDEX IF NOT EXISTS idx_cutsheetstate_updated ON CutSheetState(UpdatedAt);

-- =========================
-- Generic CutSheets (optional "defaults")
-- =========================
CREATE TABLE IF NOT EXISTS CutSheets (
  CutSheetId INTEGER PRIMARY KEY AUTOINCREMENT,
  OrderId INTEGER NOT NULL UNIQUE,
  PackagingType TEXT, -- Wrap | Vacuum (optionally enforce later)
  LabelName TEXT,
  SpecialInstructions TEXT,
  PrimaryCutThicknessInches REAL,
  PrimaryCutsPerPackage INTEGER,
  PrimaryCutNotes TEXT,
  RoastSizeLbs REAL,
  GrindPackageSizeLbs REAL,
  GrindPreference TEXT,
  GrindNotes TEXT,
  CreatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (OrderId) REFERENCES Orders(OrderId) ON DELETE CASCADE,
  CHECK (PrimaryCutsPerPackage IS NULL OR PrimaryCutsPerPackage >= 1),
  CHECK (PrimaryCutThicknessInches IS NULL OR PrimaryCutThicknessInches > 0),
  CHECK (RoastSizeLbs IS NULL OR RoastSizeLbs > 0),
  CHECK (GrindPackageSizeLbs IS NULL OR GrindPackageSizeLbs > 0)
);

CREATE INDEX IF NOT EXISTS idx_cutsheets_order ON CutSheets(OrderId);

-- =========================
-- Generic CutItems (optional per-cut details)
-- =========================
CREATE TABLE IF NOT EXISTS CutItems (
  CutItemId INTEGER PRIMARY KEY AUTOINCREMENT,
  OrderId INTEGER NOT NULL,
  CutName TEXT NOT NULL,
  ThicknessInches REAL,
  PerPackage INTEGER,
  Notes TEXT,
  FOREIGN KEY (OrderId) REFERENCES Orders(OrderId) ON DELETE CASCADE,
  CHECK (PerPackage IS NULL OR PerPackage >= 1),
  CHECK (ThicknessInches IS NULL OR ThicknessInches > 0)
);

CREATE INDEX IF NOT EXISTS idx_cutitems_order ON CutItems(OrderId);
CREATE INDEX IF NOT EXISTS idx_cutitems_cutname ON CutItems(CutName);

-- =========================
-- Daily capacity slots (per species per day)
-- =========================
CREATE TABLE IF NOT EXISTS DailySlots (
  SlotDate TEXT NOT NULL, -- YYYY-MM-DD
  Species TEXT NOT NULL CHECK (Species IN ('Beef','Hog')),
  Shop TEXT NOT NULL CHECK (Shop IN ('Don','McConnell')) DEFAULT 'Don',
  TotalSlots INTEGER NOT NULL CHECK (TotalSlots >= 0),
  ReservedSlots INTEGER NOT NULL DEFAULT 0 CHECK (ReservedSlots >= 0),
  ReservedPortionUnits INTEGER NOT NULL DEFAULT 0 CHECK (ReservedPortionUnits >= 0),
  PRIMARY KEY (SlotDate, Species, Shop),
  CHECK (ReservedPortionUnits <= TotalSlots * 4)
);

CREATE INDEX IF NOT EXISTS idx_dailyslots_date ON DailySlots(SlotDate);

-- Helpful view: availability by day/species
CREATE VIEW IF NOT EXISTS v_DailyAvailability AS
SELECT
  SlotDate,
  Species,
  TotalSlots,
  ReservedSlots,
  ReservedPortionUnits,
  (TotalSlots * 4 - ReservedPortionUnits) AS AvailablePortionUnits,
  ((TotalSlots * 4 - ReservedPortionUnits) / 4) AS AvailableAnimals
FROM DailySlots;

-- ==========================================================
-- Don's Beef Cutting List (one row per Order)
-- Apples-to-apples: explicit columns per field on the form.
-- ==========================================================
CREATE TABLE IF NOT EXISTS DonBeefCutSheets (
  DonBeefCutSheetId INTEGER PRIMARY KEY AUTOINCREMENT,
  OrderId INTEGER NOT NULL UNIQUE,

  -- Header
  CutFor TEXT,
  Phone TEXT,
  BeefFrom TEXT,

  -- FRONT QUARTER
  RibSteakThicknessIn REAL,
  RibSteakPerPackage INTEGER,
  RibEyeThicknessIn REAL,
  RibEyePerPackage INTEGER,
  RibRoastChoice TEXT CHECK (RibRoastChoice IN ('Yes','No')),
  RibRoastLbsPerRoast REAL,
  ChuckRoastLbsPerRoast REAL,
  ArmEnglishRoastLbsPerRoast REAL,
  BeefShortRibsChoice TEXT CHECK (BeefShortRibsChoice IN ('None','Some')),
  BeefShortRibsLbsPerPackage REAL,
  BeefShortRibsPackagesWanted INTEGER,

  -- HIND QUARTER
  TBoneThicknessIn REAL,
  TBonePerPackage INTEGER,
  PorterhouseThicknessIn REAL,
  PorterhousePerPackage INTEGER,
  SirloinThicknessIn REAL,
  SirloinPerPackage INTEGER,
  RoundTipChoice TEXT CHECK (RoundTipChoice IN ('Roast','Steaks','Both','None')),
  RoundTipRoastLbsEach REAL,
  RoundTipSteakThicknessIn REAL,
  RoundTipSteakPerPackage INTEGER,
  RoundSteakChoice TEXT CHECK (RoundSteakChoice IN ('AllPlain','HalfPlainHalfCubed','AllCubed')),
  RoundSteakThicknessIn REAL,
  PlainRoundSteakWholePerPackage INTEGER,
  PlainRoundSteakHalfPerPackage INTEGER,
  CubedSteakServingSizePerPackage INTEGER,
  TopRoundLbsPerRoast REAL,
  BottomRoundLbsPerRoast REAL,
  EyeOfRoundLbsPerRoast REAL,
  RumpRoastChoice TEXT CHECK (RumpRoastChoice IN ('Yes','None')),
  RumpRoastLbsPerRoast REAL,
  PotRoastChoice TEXT CHECK (PotRoastChoice IN ('Yes','None')),
  PotRoastLbsPerRoast REAL,

  -- Trim / Extras
  StewMeatChoice TEXT CHECK (StewMeatChoice IN ('No','Yes')),
  StewMeatLbsPerPackage REAL,
  StewMeatTotalPackages INTEGER,
  SoupBoilingBonesChoice TEXT CHECK (SoupBoilingBonesChoice IN ('No','Yes')),
  SoupBoilingBonesTotalPackages INTEGER,
  PlateBoilChoice TEXT CHECK (PlateBoilChoice IN ('No','Yes')),
  PlateBoilTotalPackages INTEGER,
  ShankCrossCutChoice TEXT CHECK (ShankCrossCutChoice IN ('No','Yes')),
  ShankCrossCutTotalPackages INTEGER,
  CircleChoice TEXT,
  GroundBeefLbsPerPackage REAL,
  PattiesPerPackage INTEGER,
  HowMuchMadeInPattiesLbs REAL,
  SpecialInstructions TEXT,
  CreatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (OrderId) REFERENCES Orders(OrderId) ON DELETE CASCADE,
  CHECK (RibSteakPerPackage IS NULL OR RibSteakPerPackage >= 1),
  CHECK (RibEyePerPackage IS NULL OR RibEyePerPackage >= 1),
  CHECK (TBonePerPackage IS NULL OR TBonePerPackage >= 1),
  CHECK (PorterhousePerPackage IS NULL OR PorterhousePerPackage >= 1),
  CHECK (SirloinPerPackage IS NULL OR SirloinPerPackage >= 1),
  CHECK (RoundTipSteakPerPackage IS NULL OR RoundTipSteakPerPackage >= 1),
  CHECK (PattiesPerPackage IS NULL OR PattiesPerPackage >= 1)
);

CREATE INDEX IF NOT EXISTS idx_donbeefcutsheets_order ON DonBeefCutSheets(OrderId);

-- ==========================================================
-- Don's Pork Cutting Instructions (one row per Order)
-- Apples-to-apples: explicit columns per field on the form.
-- Note: sheet circles Whole/Half hog; Orders still allows Quarter -- for your broader workflow.
-- ==========================================================
CREATE TABLE IF NOT EXISTS DonPorkCutSheets (
  DonPorkCutSheetId INTEGER PRIMARY KEY AUTOINCREMENT,
  OrderId INTEGER NOT NULL UNIQUE,

  -- Header
  CutFor TEXT,
  Phone TEXT,
  PorkFrom TEXT,

  -- Sheet circles Whole / Half
  HogChoice TEXT CHECK (HogChoice IN ('Whole','Half')),

  -- Pork chops
  PorkChopsThicknessIn REAL,
  PorkChopsPerPackage INTEGER,

  -- Pork loin roast (end cut)
  PorkLoinRoastLbsPerRoast REAL,

  -- Pork shoulder: roasts OR steaks OR picnic ham
  ShoulderChoice TEXT CHECK (ShoulderChoice IN ('Roasts','Steaks','PicnicHam','None')),
  ShoulderRoastsLbsPerRoast REAL,
  ShoulderSteaksThicknessIn REAL,
  ShoulderSteaksPerPackage INTEGER,
  PicnicHamWholeHalfSliced TEXT CHECK (PicnicHamWholeHalfSliced IN ('Whole','Half','Sliced')),

  -- Spare ribs
  SpareRibsChoice TEXT CHECK (SpareRibsChoice IN ('Cut','WholeSlab')),
  SpareRibsLbsPerCut REAL,
  SpareRibsPiecesPerPackage INTEGER,
  SpareRibsWholeSlabPerPackage INTEGER,

  -- Hams (cured & smoked) OR fresh leg
  HamChoice TEXT CHECK (HamChoice IN ('CuredSmoked','FreshLeg','None')),

  -- Cured & smoked ham: whole/half/quartered + slicing options
  CuredHamPortion TEXT CHECK (CuredHamPortion IN ('Whole','Half','Quartered')),
  CuredHamSliceStyle TEXT CHECK (CuredHamSliceStyle IN ('CenterSlices','AllSliced','None')),
  CuredHamSlicesPerPackage INTEGER,

  -- Fresh leg: whole/half/quartered OR cut into roasts (lbs)
  FreshLegPortion TEXT CHECK (FreshLegPortion IN ('Whole','Half','Quartered')),
  FreshLegCutIntoRoastsLbs REAL,

  -- Fresh leg processing options: center slices / all sliced / cubed pork steaks + slices/steaks per pkg
  FreshLegProcessStyle TEXT CHECK (FreshLegProcessStyle IN ('CenterSlices','AllSliced','CubedPorkSteaks','None')),
  FreshLegSlicesOrSteaksPerPackage INTEGER,

  -- Bacon: cured & smoked OR fresh side; lbs/pkg; slice thickness
  BaconChoice TEXT CHECK (BaconChoice IN ('CuredSmoked','FreshSide','None')),
  BaconLbsPerPackage REAL,
  BaconSliceThickness TEXT CHECK (BaconSliceThickness IN ('Thick','Medium','Thin')),

  -- Ham hocks / put into sausage
  HamHocksChoice TEXT CHECK (HamHocksChoice IN ('CuredSmoked','FreshHocks','None')),
  PutHamHocksIntoSausage INTEGER CHECK (PutHamHocksIntoSausage IN (0,1)) DEFAULT 0,

  -- Sausage
  SausageSeasoning TEXT CHECK (SausageSeasoning IN ('Plain','SaltPepper','CountryMild','SageHot','SweetItalian','HotItalian','None')),
  SausageBulk INTEGER CHECK (SausageBulk IN (0,1)) DEFAULT 0,
  SausageBulkLbsPerPackage REAL,
  SausageRegularCased INTEGER CHECK (SausageRegularCased IN (0,1)) DEFAULT 0,
  SausageRegularCasedLbsPerPackage REAL,
  SausageSmallLink INTEGER CHECK (SausageSmallLink IN (0,1)) DEFAULT 0,
  SausageSmallLinkLbsPerPackage REAL,
  SausageNotes TEXT,

  -- Organs
  LiverChoice TEXT CHECK (LiverChoice IN ('YesSliced','No','Yes')),
  HeartChoice TEXT CHECK (HeartChoice IN ('Yes','No')),
  TongueChoice TEXT CHECK (TongueChoice IN ('Yes','No')),

  SpecialInstructions TEXT,
  CreatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (OrderId) REFERENCES Orders(OrderId) ON DELETE CASCADE,
  CHECK (PorkChopsPerPackage IS NULL OR PorkChopsPerPackage >= 1),
  CHECK (ShoulderSteaksPerPackage IS NULL OR ShoulderSteaksPerPackage >= 1),
  CHECK (SpareRibsPiecesPerPackage IS NULL OR SpareRibsPiecesPerPackage >= 1),
  CHECK (CuredHamSlicesPerPackage IS NULL OR CuredHamSlicesPerPackage >= 1),
  CHECK (FreshLegSlicesOrSteaksPerPackage IS NULL OR FreshLegSlicesOrSteaksPerPackage >= 1)
);

CREATE INDEX IF NOT EXISTS idx_donporkcutsheets_order ON DonPorkCutSheets(OrderId);

COMMIT;

-- ==========================================
-- McConnell Cut Sheets
-- Mirrors McConnell paper forms (Beef + Hog)
-- ==========================================

BEGIN TRANSACTION;

-- -------------------------
-- McConnell Beef Cut Sheet
-- -------------------------
CREATE TABLE IF NOT EXISTS McConnellBeefCutSheets (
  OrderId INTEGER PRIMARY KEY,

  -- Header
  CustomerName TEXT,
  Phone TEXT,
  CallWhenReady INTEGER NOT NULL DEFAULT 0, -- 0/1
  BeefPortion TEXT NOT NULL CHECK (BeefPortion IN ('Whole','Half','FrontQuarter','HindQuarter')),
  HangingWeight REAL,

  -- Steaks / roasts
  SteaksPerPackage INTEGER,
  SteakThickness TEXT,
  ArmRoastSizeLbs REAL,
  ChuckRoastSizeLbs REAL,
  RumpRoastSizeLbs REAL,
  TipRoastSizeLbs REAL,
  RoundSteaksPerPackage INTEGER,
  RoundSteakTenderized INTEGER DEFAULT 0,
  RoundSteakPlain INTEGER DEFAULT 0,
  ShortRibs INTEGER DEFAULT 0,
  StewMeat INTEGER DEFAULT 0,

  -- Ground
  BulkGroundPkgSizeLbs REAL,
  Patties INTEGER DEFAULT 0,
  PattySize TEXT CHECK (PattySize IN ('1/4','1/2')),

  -- Offal
  Liver INTEGER DEFAULT 0,
  Heart INTEGER DEFAULT 0,
  Tongue INTEGER DEFAULT 0,
  SoupBones INTEGER DEFAULT 0,

  SpecialInstructions TEXT,
  CreatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (OrderId) REFERENCES Orders(OrderId) ON DELETE CASCADE
);

-- -------------------------
-- McConnell Hog Cut Sheet
-- -------------------------
CREATE TABLE IF NOT EXISTS McConnellHogCutSheets (
  OrderId INTEGER PRIMARY KEY,

  -- Header
  CustomerName TEXT,
  Phone TEXT,
  HogPortion TEXT NOT NULL CHECK (HogPortion IN ('Whole','Half')),
  HangingWeight REAL,

  -- Chops / loin
  PorkChopsPerPackage INTEGER,
  ChopThickness TEXT,
  ChopStyle TEXT CHECK (ChopStyle IN ('Fresh','CuredSmoked')),
  LoinRoastSizeLbs REAL,
  NoLoinRoast INTEGER DEFAULT 0,

  -- Bacon / ribs / ham
  BaconStyle TEXT CHECK (BaconStyle IN ('CuredSmoked','FreshSide')),
  CountryStyleRibs INTEGER DEFAULT 0,
  SpareRibsStyle TEXT CHECK (SpareRibsStyle IN ('Slab','Quartered')),
  HamStyle TEXT CHECK (HamStyle IN ('CuredSmoked','Fresh')),
  HamSizeLbs REAL,
  HamSliced INTEGER DEFAULT 0,
  HamWhole INTEGER DEFAULT 0,
  HamHalved INTEGER DEFAULT 0,

  -- Shoulder
  ShoulderRoastSizeLbs REAL,
  ShoulderSlicesPerPackage INTEGER,
  NoShoulder INTEGER DEFAULT 0,

  -- Sausage / grind
  GroundPork INTEGER DEFAULT 0,
  SausageRegular INTEGER DEFAULT 0,
  SausageSweetItalian INTEGER DEFAULT 0,
  SausageHotItalian INTEGER DEFAULT 0,
  SausageBulk INTEGER DEFAULT 0,
  SausageBigLinks INTEGER DEFAULT 0,
  SausageSmallLinks INTEGER DEFAULT 0,
  SausageQuarterLbPatties INTEGER DEFAULT 0,

  SpecialInstructions TEXT,
  CreatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (OrderId) REFERENCES Orders(OrderId) ON DELETE CASCADE
);

COMMIT;
