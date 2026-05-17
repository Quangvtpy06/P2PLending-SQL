-- Tạo cơ sở dữ liệu
CREATE DATABASE P2PLendingDB;
GO
USE P2PLendingDB;
GO
-- Tạo bảng BORROWER (Người vay)
CREATE TABLE BORROWER (
    BorrowerID INT PRIMARY KEY IDENTITY(1,1),
    FullName NVARCHAR(255) NOT NULL,
    Email NVARCHAR(255) NOT NULL UNIQUE,
    Phone NVARCHAR(20),
    DateOfBirth DATE,
    SSN NVARCHAR(20) UNIQUE,
    State NVARCHAR(100),
    City NVARCHAR(100),
    ZipCode NVARCHAR(20),
    EmploymentStatus NVARCHAR(50),
    AnnualIncome DECIMAL(18,2),
    DebtToIncomeRatio DECIMAL(5,2),
    CreditScore INT,
    AccountStatus NVARCHAR(50),
    RegistrationDate DATETIME DEFAULT GETDATE(),
    DigitalSignature VARBINARY(MAX)
);

-- Tạo bảng LOAN_APPLICATION (Đơn xin vay)
CREATE TABLE LOAN_APPLICATION (
    ApplicationID INT PRIMARY KEY IDENTITY(1,1),
    BorrowerID INT NOT NULL,
    RequestedAmount DECIMAL(18,2) NOT NULL,
    LoanPurpose NVARCHAR(255),
    LoanTerm INT,
    ApplicationDate DATETIME DEFAULT GETDATE(),
    ApplicationStatus NVARCHAR(50),
    RejectionReason NVARCHAR(MAX),
    FOREIGN KEY (BorrowerID) REFERENCES BORROWER(BorrowerID)
);

-- Tạo bảng CREDIT_REPORT (Báo cáo tín dụng)
CREATE TABLE CREDIT_REPORT (
    ReportID INT PRIMARY KEY IDENTITY(1,1),
    BorrowerID INT NOT NULL,
    ApplicationID INT NOT NULL,
    CreditScore INT,
	CreditHistory INT,
    OpenAccounts INT,
    TotalCreditLines DECIMAL(18,2),
    DelinquenciesLast2Yrs INT,
    PublicRecords INT,
    InquiriesLAST6Months INT,
    ReportDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (BorrowerID) REFERENCES BORROWER(BorrowerID),
    FOREIGN KEY (ApplicationID) REFERENCES LOAN_APPLICATION(ApplicationID)
);

-- Tạo bảng INVESTOR (Nhà đầu tư)
CREATE TABLE INVESTOR (
    InvestorID INT PRIMARY KEY IDENTITY(1,1),
    FullName NVARCHAR(255) NOT NULL,
    Email NVARCHAR(255) NOT NULL UNIQUE,
    Phone NVARCHAR(20),
	State NVARCHAR(20),
    InvestorType NVARCHAR(50),
    AccreditationStatus NVARCHAR(50),
    MinInvestmentAmount DECIMAL(18,2),
    TotalInvested DECIMAL(18,2),
    AccountBalance DECIMAL(18,2),
    RegistrationDate DATETIME DEFAULT GETDATE(),
    DigitalSignature VARBINARY(MAX)
);

-- Tạo bảng CONTRACT (Hợp đồng)
CREATE TABLE CONTRACT (
    ContractID INT PRIMARY KEY IDENTITY(1,1),
    BorrowerID INT NOT NULL,
    InvestorID INT NOT NULL,
    ApplicationID INT NOT NULL,
    PrincipalAmount DECIMAL(18,2) NOT NULL,
    InterestRate DECIMAL(5,2) NOT NULL,
    Term INT NOT NULL,
    PenaltyRate DECIMAL(5,2),
    PlatformFeeRate DECIMAL(18,2),
    CreatedDate DATETIME DEFAULT GETDATE(),
    EffectiveDate DATETIME,
    MaturityDate DATETIME,
    BorrowerSignature NVARCHAR(MAX),
    InvestorSignature NVARCHAR(MAX),
    Status NVARCHAR(50),
    FOREIGN KEY (BorrowerID) REFERENCES BORROWER(BorrowerID),
    FOREIGN KEY (InvestorID) REFERENCES INVESTOR(InvestorID),
    FOREIGN KEY (ApplicationID) REFERENCES LOAN_APPLICATION(ApplicationID)
);

-- Tạo bảng INVESTMENTS (Đầu tư)
CREATE TABLE INVESTMENTS (
    InvestmentID INT PRIMARY KEY IDENTITY(1,1),
    ContractID INT NOT NULL,
    InvestorID INT NOT NULL,
    InvestedAmount DECIMAL(18,2) NOT NULL,
    InvestmentPercentage DECIMAL(5,2),
    ExpectedAmount DECIMAL(18,2),
    ActualReturn DECIMAL(18,2),
    InvestmentStatus NVARCHAR(50),
    InvestmentDate DATE,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ContractID) REFERENCES CONTRACT(ContractID),
    FOREIGN KEY (InvestorID) REFERENCES INVESTOR(InvestorID)
);

-- Tạo bảng DISBURSEMENT (Giải ngân)
CREATE TABLE DISBURSEMENT (
    DisbursementID INT PRIMARY KEY IDENTITY(1,1),
    DScheduleID INT NOT NULL,
    InvestorID INT NOT NULL,
	TrancheNumber INT NOT NULL,
    GrossAmount DECIMAL(18,2) NOT NULL,
    NetAmount DECIMAL(18,2),
    Currency NVARCHAR(10) DEFAULT 'VND',
    TransactionDate DATETIME DEFAULT GETDATE(),
    BeneficiaryAccount NVARCHAR(50),
    BeneficiaryBank NVARCHAR(255),
    BeneficiaryName NVARCHAR(50),
    FOREIGN KEY (DScheduleID) REFERENCES CONTRACT(ContractID),
    FOREIGN KEY (InvestorID) REFERENCES INVESTOR(InvestorID)
);

-- Tạo bảng DISBURSEMENT_SCHEDULE (Lịch giải ngân)
CREATE TABLE DISBURSEMENT_SCHEDULE (
    DScheduleID INT PRIMARY KEY IDENTITY(1,1),
    ContractID INT NOT NULL,
    DisbursementID INT NOT NULL,
    ExpectedDate DATETIME,
    ExpectedAmount DECIMAL(18,2),
    Condition NVARCHAR(MAX),
    Status NVARCHAR(50),
    FOREIGN KEY (ContractID) REFERENCES CONTRACT(ContractID),
    FOREIGN KEY (DisbursementID) REFERENCES DISBURSEMENT(DisbursementID)
);

-- Tạo bảng REPAYMENT (Trả nợ)
CREATE TABLE REPAYMENT (
    RepaymentID INT PRIMARY KEY IDENTITY(1,1),
    ContractID INT NOT NULL,
    BorrowerID INT NOT NULL,
	InstallmentNumber INT NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    TransactionDate DATETIME DEFAULT GETDATE(),
    Status NVARCHAR(50),
    FOREIGN KEY (ContractID) REFERENCES CONTRACT(ContractID),
    FOREIGN KEY (BorrowerID) REFERENCES BORROWER(BorrowerID)
);

-- Tạo bảng REPAYMENT_SCHEDULE (Lịch trả nợ)
CREATE TABLE REPAYMENT_SCHEDULE (
    RScheduleID INT PRIMARY KEY IDENTITY(1,1),
    ContractID INT NOT NULL,
    DueDate DATETIME NOT NULL,
    Status NVARCHAR(50),
    LateFee DECIMAL(18,2) DEFAULT 0,
    PenaltyInterest DECIMAL(18,2) DEFAULT 0,
    FOREIGN KEY (ContractID) REFERENCES CONTRACT(ContractID)
);