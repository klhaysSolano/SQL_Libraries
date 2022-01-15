/** Pretiral Status - ORAS-PAT **/
DECLARE @BegDate AS Date
DECLARE @endDate AS Date
SET @BegDate = '01-01-2020'
SET @endDate = '12-31-2020'

SELECT DISTINCT
  per.id as IndiviudalID,
  per.firstName,
  per.lastName,
  pf.gender as Gender,
  dbo.LKP_LABEL('RACE_TYPE', pf.race) AS Ethnicity,
  Format(pf.dateOfBirth, 'MM/dd/yyyy') as DateOfBirth,
  DATEDIFF(YY, pf.dateOfBirth, GETDATE()) -
    CASE --Age Calculation
    WHEN DATEADD(YY,DATEDIFF(YY, pf.dateOfBirth, GETDATE()), pf.dateOfBirth)
        > GETDATE() THEN 1
        ELSE 0
        End AS [Age],
  ad.city,
  ad.zip,
  cc.caseNumber,
  --(select label from ecourt.tLookupItem where code = th.courtCaseStatus and lookupList_id = (select id from ecourt.tLookupList where name = 'COURTCASE_STATUS')) as ccs,
  dbo.LKP_LABEL('COURTCASE_STATUS', th.courtCaseStatus) AS CourtCaseStatus,
  format(th.begEffDate,'MM/dd/yyyy') as StatusDate,
  dbo.LKP_LABEL('RISK_ASSESSMENT_TYPE', ase.assessmentType) AS AssessmentType,
  
  CASE
	WHEN ase.assessmentDate BETWEEN '01-01-2020' and '12-31-2020' THEN FORMAT(ase.assessmentDate, 'MM/dd/yyyy')
	ELSE NULL
	END as [AssessmentDate],

  --FORMAT(ase.assessmentDate, 'MM/dd/yyyy') as AssessmentDate,
  
  CASE
	WHEN ase.assessmentDate  BETWEEN '01-01-2020' and '12-31-2020' THEN dbo.LKP_LABEL('SCP_RISK_SCORE', ase.scp_assessmentScore) 
	ELSE NULL
	END as [AssessmentScore],

  CASE
	WHEN ase.assessmentDate > MAX(ase.assessmentDate) OVER ()
	THEN NULL 
	WHEN ase.assessmentDate BETWEEN '01-01-2020' and '12-31-2020' THEN FORMAT(ase.assessmentDate, 'MM/dd/yyyy')
	ELSE NULL end as MAXDATE

  --dbo.LKP_LABEL('SCP_RISK_SCORE', ase.scp_assessmentScore) AS RiskScore
  
FROM ecourt.tScp_courtCaseStatus th 
    JOIN ecourt.tcase cc ON cc.id = th.case_id AND cc.caseType = 'CC' 
    JOIN ecourt.tCase_tSubCase ccc ON ccc.sup_courtCases_id = cc.id 
    JOIN ecourt.tSubCase sc ON sc.id = ccc.sup_clients_id and sc.subCaseType = 'PREREF' 
    JOIN ecourt.tCase ca ON ca.id = sc.case_id 
    JOIN ecourt.tParty pt ON ca.id = pt.case_id
    JOIN ecourt.tPerson per ON pt.person_id = per.id
    JOIN ecourt.tPersonProfile PF ON pf.associatedPerson_id = per.id 
    JOIN ecourt.tAddress ad ON ad.associatedPerson_id = per.id AND ad.preferred = '1'
    JOIN ecourt.tSup_asessmentScore ase ON ase.case_id = ca.id

WHERE
  th.courtCaseStatus IN('49','50','51','52','53','55','56','57','58','59','60','61','62','63','64','66','67','70','CCS53','CCS60','CCS70','CCS71') AND 
  ase.assessmentType in('11437','CEAT18') AND 
  th.begEffDate BETWEEN @BegDate AND @endDate
  --AND ase.assessmentdate BETWEEN '01-01-2020' and '12-31-2020'

ORDER BY per.id



