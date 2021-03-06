/*************************************
Prerequisites: 
get atc_drug_scraper using atc-grabber
************************************/

drop table atc_1;
create table atc_1 as
select * from atc_drug_scraper
where length (atc_code) = 7;

-- table with dosages
create table atc_1_dos
as 
select * from atc_1
where ddd is not null;

--table with combos
drop table atc_1_comb;
create table atc_1_comb
as
select * from atc_1
where atc_name ~ 'comb| and |diphtheria-|meningococcus|excl|derivate|other|with'
and not atc_name ~ 'decarboxylase inhibitor';

delete from atc_1
where atc_code in
(select atc_code from atc_1_comb);

/***  no mapping in one of the combos, exclude from mappings ***/
--!!!remove, put in QA
delete from atc_1_comb where atc_name ~ 'arterolane|betamipron|chloroprednisone|epitizide|methylnortestosterone|panipenem|picodralazine|pyronaridine|syrosingopine|trimegestone|tropenzilone';


-- watch for A01 - stomatological
-- additionally need to map
create table manual as
select * from atc_1_comb where atc_name like 'meningo%';
insert into manual
select * from atc_1 where atc_name like '%sodium chloride, hypertonic%';
insert into manual
select * from atc_1_comb where atc_name like '%hemophilus influenzae B%';
insert into manual
select * from atc_1_comb where atc_name like '%hepatitis B%';
insert into manual
select * from atc_1_comb where atc_name like '%beta-lactamase inhibitor%';
insert into manual
select * from atc_1_comb where atc_name like '%decarboxylase inhibitor%';
insert into manual
select * from atc_1_comb where atc_name like '%mould fungus%';
insert into manual
select * from atc_1_comb where atc_name like '%ordinary salt%';


--bckps
create table drug_concept_stage_1
as select * from drug_concept_stage;
create table internal_relationship_stage_1
as select * from internal_relationship_stage;
create table ds_stage_1
as select * from ds_stage;
create table relationship_to_concept_1
as select * from relationship_to_concept;
create table dev_ingredient_stage_1
as select * from dev_ingredient_stage;


--fix the data shift from the website
update atc_drugs_scraper
set ddd = 60, u = 'mg',adm_r = 'O'
where atc_code = 'B01AF03';

-- updating source data: forms
UPDATE atc_1_comb
SET atc_name = 'progestogen and estrogen',
    adm_r = 'V'
WHERE atc_code = 'G02BB01';


--medicated shampoos
--('D11AC01','D11AC02','D11AC03','D11AC06','D11AC08','D11AC09','D11AC30')


 -- add buccal and others
 -- not included: lamella
drop table if exists forms ;
create table forms as
(
select concept_name as form, 'inhal' as label
from concept
where concept_class_id = 'Dose Form' and concept_name like '%Inhal%' and concept_name not like '%Nasal%' and vocabulary_id like 'RxNorm%' and invalid_reason is null

union all

select concept_name, 'oph' as flag
from concept
where concept_class_id = 'Dose Form' and concept_name like '%Ophthal%' and vocabulary_id like '%RxNorm%' and invalid_reason is null

union all

select concept_name, 'p' as flag
from concept
where concept_class_id = 'Dose Form' and concept_name ~ 'Oral|Inject|Cartridge|Syringe|Intra|Implant' and vocabulary_id like 'RxNorm%' and invalid_reason is null

union all

select concept_name, 's' as flag
from concept
where concept_class_id = 'Dose Form' and concept_name ~ 'Oral|Inject|Cartridge|Syringe|Intra|Oral|Implant' and vocabulary_id like 'RxNorm%' and invalid_reason is null

union all

select concept_name, 'o' as flag
from concept
where concept_class_id = 'Dose Form' and concept_name like '%Oral|Chewab%' and vocabulary_id like 'RxNorm%' and invalid_reason is null

union all

select concept_name, 'dressing' as flag
from concept
where concept_class_id = 'Dose Form' and concept_name = 'Medicated Pad' and vocabulary_id like 'RxNorm%' and invalid_reason is null

union all

select concept_name, 'td' as flag
from concept
where concept_class_id = 'Dose Form' and (concept_name like 'Transdermal%' or concept_name = 'Topical gel') and vocabulary_id like 'RxNorm%' and invalid_reason is null
    
union all
    
select concept_name, 'td patch' as flag
from concept
where concept_class_id = 'Dose Form' and concept_name = 'Transdermal%' and vocabulary_id like 'RxNorm%' and invalid_reason is null
    --TD
    --TD patch
    
select concept_name, 'i' as flag
from concept
where concept_class_id = 'Dose Form' and concept_name = 'Irrigation Solution' and vocabulary_id like 'RxNorm%' and invalid_reason is null

union all

select concept_name, 't' as flag
from concept
where concept_class_id = 'Dose Form' and concept_name like '%Topical%' and vocabulary_id like 'RxNorm%' and invalid_reason is null

union all

select concept_name, 'ot' as flag
from concept
where concept_class_id = 'Dose Form' and concept_name like '%Otic%' and vocabulary_id like 'RxNorm%' and invalid_reason is null

union all

select concept_name, 'e' as flag
from concept
where concept_class_id = 'Dose Form' and concept_name in ('Enema','Rectal Suspension','Rectal Solution') and vocabulary_id like 'RxNorm%' and invalid_reason is null

union all

select concept_name, 'v' as flag
from concept
where concept_class_id = 'Dose Form' and concept_name like '%Vaginal%' and vocabulary_id like 'RxNorm%' and invalid_reason is null

union all
    
select concept_name, 'r' as flag
from concept
where concept_class_id = 'Dose Form' and concept_name ~ 'Rectal|Enema' and vocabulary_id like 'RxNorm%' and invalid_reason is null  
    
union all    

select concept_name, 'n' as flag
from concept
where concept_class_id = 'Dose Form' and concept_name like '%Nasal%' and vocabulary_id like 'RxNorm%' and invalid_reason is null

union all

select concept_name, 'sl' as flag
from concept
where concept_class_id = 'Dose Form' and concept_name like '%Sublingual%' and vocabulary_id like 'RxNorm%' and invalid_reason is null

union all
    
select concept_name, 'sl' as flag
from concept
where concept_class_id = 'Dose Form' and concept_name like '%Sublingual%' and vocabulary_id like 'RxNorm%' and invalid_reason is null

union all
    
select concept_name, 'sl' as flag
from concept
where concept_class_id = 'Dose Form' and concept_name like '%Sublingual%' and vocabulary_id like 'RxNorm%' and invalid_reason is null

union all
    
select concept_name, 'chewing gum' as flag
from concept
where concept_class_id = 'Dose Form' and concept_name = 'chewing gum' and vocabulary_id like 'RxNorm%' and invalid_reason is null

union all
    
select concept_name, 'implant' as flag
from concept
where concept_class_id = 'Dose Form' and concept_name = 'Drug Implant' and vocabulary_id like 'RxNorm%' and invalid_reason is null

union all
    
select concept_name, 'intravesical' as flag
from concept
where concept_class_id = 'Dose Form' and concept_name = 'Irrigation Solution' and vocabulary_id like 'RxNorm%' and invalid_reason is null

union all
    
select concept_name, 'ointment' as flag
from concept
where concept_class_id = 'Dose Form' and concept_name ~ 'Cream|Ointment' and vocabulary_id like 'RxNorm%' and invalid_reason is null
    
union all
    
select concept_name, 'oral aerosol' as flag
from concept
where concept_class_id = 'Dose Form' and concept_name like 'Oral Spray' and vocabulary_id like 'RxNorm%' and invalid_reason is null

union all
    
select concept_name, 's.c. implant' as flag
from concept
where concept_class_id = 'Dose Form' and concept_name in ('Drug Implant') and vocabulary_id like 'RxNorm%' and invalid_reason is null

union all
    
select concept_name, 'inh.aerosol' as flag
from concept
where concept_class_id = 'Dose Form' and concept_name like '%Sublingual%' and vocabulary_id like 'RxNorm%' and invalid_reason is null
  
union all
    
select concept_name, 'inhal. powder' as flag
from concept
where concept_class_id = 'Dose Form' and concept_name in ('Inhalant Powder','Metered Dose Inhaler','Dry Powder Inhaler') and vocabulary_id like 'RxNorm%' and invalid_reason is null

    
union all
    
select concept_name, 'inhal.aerosol' as flag
from concept
where concept_class_id = 'Dose Form' and concept_name in ('Nasal Inhaler','Metered Dose Inhaler') and vocabulary_id like 'RxNorm%' and invalid_reason is null

    
union all
    
select concept_name, 'inhal.powder' as flag
from concept
where concept_class_id = 'Dose Form' and concept_name in ('Inhalant Powder','Metered Dose Inhaler','Dry Powder Inhaler') and vocabulary_id like 'RxNorm%' and invalid_reason is null

    
union all
    
select concept_name, 'inhal.solution' as flag
from concept
where concept_class_id = 'Dose Form' and concept_name = 'Inhalant Solution' and vocabulary_id like 'RxNorm%' and invalid_reason is null

union all
    
select concept_name, 'instill.sol.' as flag
from concept
where concept_class_id = 'Dose Form' and concept_name in ('Topical Solution','Irrigation Solution') and vocabulary_id like 'RxNorm%' and invalid_reason is null

);

insert into forms 
select distinct c2.concept_name, 'th'
from concept c 
join concept_relationship cr on cr.concept_id_1 = c.concept_id and cr.invalid_reason is null and cr.relationship_id = 'ATC - RxNorm'
join concept_relationship cr2 on cr.concept_id_2 = cr2.concept_id_1 and cr2.invalid_reason is null and cr2.relationship_id = 'RxNorm has dose form'
join concept c2 on cr2.concept_id_2 = c2.concept_id and c2.vocabulary_id = 'RxNorm' 
where c.concept_code like 'R02%' and c.vocabulary_id = 'ATC'
and c2.concept_name not like 'Topical%' -- Exclude Topical route from throat preparation

union all

select distinct c2.concept_name, 'lo' --local oral
from concept c 
join concept_relationship cr on cr.concept_id_1 = c.concept_id and cr.invalid_reason is null and cr.relationship_id = 'ATC - RxNorm'
join concept_relationship cr2 on cr.concept_id_2 = cr2.concept_id_1  and cr2.relationship_id = 'RxNorm has dose form'
join concept c2 on cr2.concept_id_2 = c2.concept_id and c2.vocabulary_id = 'RxNorm' 
where c.concept_code like 'A01A%' and c.vocabulary_id = 'ATC'
;

-- creating reference table with atc_code and corresonding code+form
create table reference as
select atc_code, 
case when form is not null then atc_code||' '||form else atc_code end as concept_code
from atc_drugs_scraper
left join forms on lower(label) = lower(adm_r);

insert into reference
values ('G02BB01','G02BB01 Vaginal Ring');

--TD note case when !!!
--gel!!!


/******DRUG_CONCEPT_STAGE******/

-- 1. Drugs
insert into drug_concept_stage (CONCEPT_NAME,VOCABULARY_ID,CONCEPT_CLASS_ID,STANDARD_CONCEPT,CONCEPT_CODE,POSSIBLE_EXCIPIENT,DOMAIN_ID,VALID_START_DATE,VALID_END_DATE,INVALID_REASON,SOURCE_CONCEPT_CLASS_ID)
select atc_name, 'ATC', 'Drug Product', 'S', coalesce(concept_code,atc_code) , null, 'Drug' ,to_date('19700101','YYYYMMDD'),to_date ('20991231','YYYYMMDD'), null, null
from reference
;
-- 2. Dose Forms
insert into drug_concept_stage (CONCEPT_NAME,VOCABULARY_ID,CONCEPT_CLASS_ID,STANDARD_CONCEPT,CONCEPT_CODE,POSSIBLE_EXCIPIENT,DOMAIN_ID,VALID_START_DATE,VALID_END_DATE,INVALID_REASON,SOURCE_CONCEPT_CLASS_ID)
select concept_name, 'ATC', 'Dose Form', null, concept_name , null, 'Drug' , to_date ('19700101','YYYYMMDD'),to_date ('20991231','YYYYMMDD'), null, null
from concept 
where vocabulary_id like 'RxNorm%' and invalid_reason is null and concept_class_id = 'Dose Form'
;

-- 3. Ingredients
--non-combo
insert into drug_concept_stage
select distinct atc_name, 'ATC','Ingredient','S',atc_name, null,'Drug',current_date, to_date ('20991231','YYYYMMDD'), null, null
from atc_1
;

--inserting combos
insert into drug_concept_stage
select distinct trim(unnest(string_to_array(atc_name, ' and '))), 'ATC','Ingredient','S',trim(unnest(string_to_array(atc_name, ' and '))), null,'Drug',current_date, to_date ('YYYYMMDD','20991231'), null, null
from 
atc_1_comb where atc_name not like '%,%' and atc_name not like '%comb%' and atc_name not like '%other%' and atc_name like '% and %'
and atc_name not in ('omega-3-triglycerides incl. other esters and acids') -- process separately
and trim(unnest(string_to_array(atc_name, ' and '))) not in
(select concept_name from drug_concept_stage)
;

--comb
insert into drug_concept_stage
select distinct regexp_replace (atc_name,'((, incl\.)?(,)? combinations)| in combination( with other drugs)?',''), 'ATC','Ingredient','S', regexp_replace (atc_name,'((, incl\.)?(,)? combinations)| in combination( with other drugs)?',''), null,'Drug',current_date, to_date ('YYYYMMDD','20991231'), null, null
from atc_1_comb
where atc_name  like '%comb%' and atc_name not like '% and %'
and not atc_name ~ 'excl|combinations of|derivate|other|with'
and regexp_replace (atc_name,'((, incl\.)?(,)? combinations)| in combination( with other drugs)?','')   not in ('various','combinations') -- exclude from search
and  regexp_replace (atc_name,'((, incl\.)?(,)? combinations)| in combination( with other drugs)?','')  not in
(select concept_code from drug_concept_stage)
;

--quinupristin/dalfopristin
insert into drug_concept_stage
select 'quinupristin', 'ATC','Ingredient','S','quinupristin', null,'Drug',current_date, to_date ('20991231','YYYYMMDD'), null, null;
insert into drug_concept_stage
select 'dalfopristin', 'ATC','Ingredient','S', 'dalfopristin', null,'Drug',current_date, to_date ('20991231','YYYYMMDD'), null, null;


/*insert into internal_relationship_stage (concept_code_1, concept_code_2)
with primary_table as (select * from atc_drugs_scraper
where length(atc_code) = 7
and atc_name like '%and %')
select atc_code||' '||concept_name, atc_code||'-'||split_part(atc_name, 'and ', 2) from primary_table, dev_oral
where atc_name not like '%,%'
and atc_name not like '%combination%'
and adm_r = 'O'
*/



/****IRS****/

-- Ingredient
--insert ingredients from non_combo drugs
insert into internal_relationship_stage
select distinct concept_code,atc_name from atc_1
join reference r using (atc_code)  
where r.concept_code not in 
(select concept_code_1 from internal_relationship_stage
join drug_concept_stage on concept_code_2=concept_code and concept_class_id='Ingredient');

insert into internal_relationship_stage
select distinct coalesce (concept_code,atc_code), trim(unnest(string_to_array(atc_name, ' and ')))
from 
atc_1_comb 
left join reference using (atc_code)
where atc_name not like '%,%' and atc_name not like '%comb%' and atc_name not like '%other%'  and atc_name like '% and %'
and atc_name not in ('omega-3-triglycerides incl. other esters and acids');

insert into internal_relationship_stage
select coalesce (concept_code,atc_code), regexp_replace (atc_name,'((, incl\.)?(,)? combinations)| in combination( with other drugs)?','')
from atc_1_comb
left join reference using (atc_code)
where atc_name  like '%comb%' and atc_name not like '% and %'
and not atc_name ~ 'excl|combinations of|derivate|other|with'
and regexp_replace (atc_name,'((, incl\.)?(,)? combinations)| in combination( with other drugs)?','')   not in ('various','combinations') -- exclude from search
and coalesce (concept_code,atc_code) not in (select concept_code_1 from internal_relationship_stage join drug_concept_stage on concept_code_2 = concept_code and concept_class_id = 'Ingredient') ;

-- manual
--quinupristin/dalfopristin
insert into internal_relationship_stage
select concept_code_1,'quinupristin' from internal_relationship_stage where concept_code_2='quinupristin/dalfopristin';
insert into internal_relationship_stage
select concept_code_1,'dalfopristin' from internal_relationship_stage where concept_code_2='quinupristin/dalfopristin';
delete from internal_relationship_stage where concept_code_2='quinupristin/dalfopristin';

-- Dose Forms
insert into internal_relationship_stage
select concept_code, regexp_replace(concept_code,'\w+ ','')
from reference;


--missing forms
-- create intermediate tables with forms identified based on parent ATC codes
drop table systemic;
create table systemic as
select atc_code from reference where concept_code ~ 'R03C|A14|D10B|D01B|R06|D05B|H02|G03A|R03D|^H|^J'
and atc_code=concept_code
and atc_code not like 'S02%' and atc_code not like 'D04%';

drop table rectal;
create table rectal as
select atc_code from reference where concept_code ~'C05A'
and atc_code = concept_code;

drop table nasal;
create table nasal as
select atc_code from reference where concept_code  ~ 'R01' and not concept_code  ~ '^R01B'
and atc_code=concept_code;

drop table irrig;
create table irrig as
select atc_code from reference where concept_code  ~ 'B05C'
and atc_code=concept_code;

drop table inhal;
create table inhal as
select atc_code from reference where concept_code  ~ 'R03B|R03AC05'--rimiterol
and atc_code=concept_code;

drop table dressing;
create table dressing as
select atc_code from reference where concept_code  ~ '^D09'
and atc_code=concept_code;

drop table oral;
create table oral as
select atc_code from reference where concept_code  ~ 'A07|R01B|V04CA02|A06AD'-- V04CA02 oral glucose tolerance test; A06AD - oral laxatives
and atc_code=concept_code
and atc_code not like 'S02%';

drop table parent;
create table parent as
select atc_code from reference where concept_code  ~ 'B05A|B05Z|B05X|B05D|B05B|R07AA02|L03AX10'--natural phospholipids, immunocyanin
and atc_code=concept_code;

drop table ophth;
create table ophth as
select atc_code from reference where concept_code  ~ 'S03|S01|S01X|S01XA20'
and atc_code=concept_code;

drop table otic;
create table otic as
select atc_code from reference where concept_code  like 'S02%'
and atc_code=concept_code;
 
drop table topical;
create table topical as
select atc_code from reference where concept_code  ~ 'M02|R01A|D05A|D06B|G02B|D01A|D10A|R01AA14|B02BC|N01B|C05BA|^D'
and atc_code=concept_code;

drop table throat;
create table throat as
select atc_code from reference where concept_code  like 'R02%'
and atc_code=concept_code;

drop table enema;
create table enema as
select atc_code from reference where concept_code  like 'A06AG%'
and atc_code=concept_code;

drop table vaginal;
create table vaginal as
select atc_code from reference where concept_code ~ 'G02CC|G01A'
and atc_code=concept_code;

drop table localoral;
create table localoral as
select atc_code from reference where concept_code  like 'A01A%'
and atc_code=concept_code;

--repeate for all
delete from reference where atc_code in (select atc_code from systemic);
insert into reference 
select distinct atc_code, atc_code||' '||form
from 
(select atc_code, 's' as label from systemic) s
join forms using (label);

insert into drug_concept_stage
select distinct atc_code||' '||form,'ATC','Drug Product',null,atc_code||' '||form, null,'Drug',current_date, to_date ('20991231','YYYYMMDD'), null, null
from 
(select atc_code, 's' as label from systemic) s
join forms using (label);

delete from drug_concept_stage where concept_code in
(select atc_code from systemic);

insert into internal_relationship_stage
select distinct new_code, concept_code_2 from internal_relationship_stage 
join  
( select atc_code||' '||form as new_code, form,atc_code from 
(select atc_code, 's' as label from systemic) s
join forms using (label)) s
on atc_code = concept_code_1;

insert into internal_relationship_stage
select distinct new_code, form from internal_relationship_stage 
join  
( select atc_code||' '||form as new_code, form,atc_code from 
(select atc_code, 's' as label from systemic) s
join forms using (label)) s
on atc_code = concept_code_1;

delete from internal_relationship_stage
where concept_code_1 in
( select atc_code from 
(select atc_code, 's' as label from systemic) s
join forms using (label)) ;


/** RTC ***/



-- started processing groups using ATC/SNOMED/NDFRT with manual exclusions

insert into dev_ingredient_stage (source_concept_name,source_vocabulary_id,source_concept_class_id,source_concept_code)
select d.concept_name, d.vocabulary_id, concept_class_id, d.concept_name  from drug_concept_stage d
left join relationship_to_concept on concept_code_1=concept_code 
where concept_id_2 is null and concept_class_id = 'Ingredient'
and concept_name not in
(select source_concept_name from dev_ingredient_stage)
;
INSERT INTO dev_ingredient_stage(  source_concept_name,  source_vocabulary_id,  source_concept_class_id,  source_concept_code,  maps_to,  concept_id,  concept_name,  vocabulary_id)
VALUES(  'quinupristin',  'ATC',  'Ingredient',  'quinupristin',  NULL,  1789515,  NULL,  NULL);
INSERT INTO dev_ingredient_stage(  source_concept_name,  source_vocabulary_id,  source_concept_class_id,  source_concept_code,  maps_to,  concept_id,  concept_name,  vocabulary_id)
VALUES(  'dalfopristin',  'ATC',  'Ingredient',  'dalfopristin',  NULL,  1789517,  NULL,  NULL);

insert into dev_ingredient_stage
SELECT distinct  'antibiotics','ATC','Ingredient','antibiotics',null, concept_id,concept_name,vocabulary_id
FROM devv5.concept_ancestor  -- antibiotic agents
  JOIN concept c ON descendant_concept_id = c.concept_id
  AND ancestor_concept_id IN ( 40182597,40194036,21602796,21600602,21601616,21601910,21602055,21603073,21603095,21603235,21603553 ) 
  AND vocabulary_id like 'RxNorm%' and concept_class_id = 'Ingredient' and concept_id not in (42800027,40166605)
;
delete from dev_ingredient_stage where source_concept_name='antibiotics' and concept_id is null;

insert into dev_ingredient_stage
SELECT distinct  'antiseptics','ATC','Ingredient','antiseptics',null, concept_id,concept_name,vocabulary_id
FROM devv5.concept_ancestor  -- antibiotic agents
  JOIN concept c ON descendant_concept_id = c.concept_id
  AND ancestor_concept_id IN (4337018,40218829,21603217) 
  AND vocabulary_id like 'RxNorm%' and concept_class_id = 'Ingredient' and concept_id not in (42800027,40166605)
;
delete from dev_ingredient_stage where source_concept_name='antiseptics' and concept_id is null;

insert into dev_ingredient_stage
SELECT 'mucolytics','ATC','Ingredient','mucolytics',null, concept_id,concept_name,vocabulary_id
FROM devv5.concept_relationship cr
  JOIN devv5.concept_relationship cr2 ON cr.concept_id_2 = cr2.concept_id_1 AND cr.relationship_id = 'Subsumes'  AND cr2.relationship_id = 'SNOMED - RxNorm eq' 
  AND cr.invalid_reason IS NULL AND cr2.invalid_reason IS NULL
  JOIN concept ON concept_id = cr2.concept_id_2 AND standard_concept = 'S'
WHERE cr.concept_id_1 = 4187017
;
delete from dev_ingredient_stage where source_concept_name='mucolytics' and concept_id is null;

insert into dev_ingredient_stage
SELECT 'adrenergics','ATC','Ingredient','adrenergics',null, concept_id,concept_name,vocabulary_id
FROM devv5.concept_relationship cr
  JOIN devv5.concept_relationship cr2 ON cr.concept_id_2 = cr2.concept_id_1 AND cr.relationship_id = 'Subsumes'  AND cr2.relationship_id = 'SNOMED - RxNorm eq' 
  AND cr.invalid_reason IS NULL AND cr2.invalid_reason IS NULL
  JOIN concept ON concept_id = cr2.concept_id_2 AND standard_concept = 'S'
WHERE cr.concept_id_1 = 4313435
;
delete from dev_ingredient_stage where source_concept_name='adrenergics' and concept_id is null;

insert into dev_ingredient_stage
SELECT 'cough suppressants','ATC','Ingredient','cough suppressants',null, concept_id,concept_name,vocabulary_id
FROM devv5.concept_relationship cr
  JOIN devv5.concept_relationship cr2 ON cr.concept_id_2 = cr2.concept_id_1 AND cr.relationship_id = 'Subsumes'  AND cr2.relationship_id = 'SNOMED - RxNorm eq' 
  AND cr.invalid_reason IS NULL AND cr2.invalid_reason IS NULL
  JOIN concept ON concept_id = cr2.concept_id_2 AND standard_concept = 'S'
WHERE cr.concept_id_1 = 4313435
;
delete from dev_ingredient_stage where source_concept_name='cough suppressants' and concept_id is null;

insert into dev_ingredient_stage
SELECT 'expectorants','ATC','Ingredient','expectorants',null, case when concept_id = 1189236 then 1189220 else concept_id end,concept_name,vocabulary_id
FROM devv5.concept_relationship cr
  JOIN devv5.concept_relationship cr2 ON cr.concept_id_2 = cr2.concept_id_1 AND cr.relationship_id = 'Subsumes'  AND cr2.relationship_id = 'SNOMED - RxNorm eq' 
  AND cr.invalid_reason IS NULL AND cr2.invalid_reason IS NULL
  JOIN concept ON concept_id = cr2.concept_id_2 AND standard_concept = 'S'
WHERE cr.concept_id_1 = 4302332
;
delete from dev_ingredient_stage where source_concept_name='expectorants' and concept_id is null;

insert into dev_ingredient_stage
SELECT distinct  'thiazides','ATC','Ingredient','thiazides',null, concept_id,concept_name,vocabulary_id
FROM devv5.concept_ancestor  -- antibiotic agents
  JOIN concept c ON descendant_concept_id = c.concept_id
  AND ancestor_concept_id IN (4251718) 
  AND vocabulary_id like 'RxNorm%' and concept_class_id = 'Ingredient' and concept_id not in (1326378,19049105)
;
delete from dev_ingredient_stage where source_concept_name='thiazides' and concept_id is null;

insert into dev_ingredient_stage
SELECT distinct  'cannabinoids','ATC','Ingredient','cannabinoids',null, concept_id,concept_name,vocabulary_id
FROM devv5.concept_ancestor  -- antibiotic agents
  JOIN concept c ON descendant_concept_id = c.concept_id
  AND ancestor_concept_id IN (4327210) 
  AND vocabulary_id like 'RxNorm%' and concept_class_id = 'Ingredient' and concept_id not in (1326378,19049105)
;
delete from dev_ingredient_stage where source_concept_name='cannabinoids' and concept_id is null;

insert into dev_ingredient_stage
SELECT distinct  'potassium-sparing agents','ATC','Ingredient','potassium-sparing agents',null, concept_id,concept_name,vocabulary_id
FROM devv5.concept_ancestor  -- antibiotic agents
  JOIN concept c ON descendant_concept_id = c.concept_id
  AND ancestor_concept_id IN (21601532) 
  AND vocabulary_id like 'RxNorm%' and concept_class_id = 'Ingredient' and concept_id not in (1326378,19049105)
;
delete from dev_ingredient_stage where source_concept_name='potassium-sparing agents' and concept_id is null;

insert into dev_ingredient_stage
SELECT distinct  'mydriatics','ATC','Ingredient','mydriatics',null, concept_id,concept_name,vocabulary_id
FROM devv5.concept_ancestor  -- antibiotic agents
  JOIN concept c ON descendant_concept_id = c.concept_id
  AND ancestor_concept_id IN (21605059) 
  AND vocabulary_id like 'RxNorm%' and concept_class_id = 'Ingredient' and concept_id not in (1326378,19049105)
;
delete from dev_ingredient_stage where source_concept_name='mydriatics' and concept_id is null;

insert into dev_ingredient_stage
SELECT distinct  'lactic acid producing organisms','ATC','Ingredient','lactic acid producing organisms',null, concept_id,concept_name,vocabulary_id
from concept where vocabulary_id like 'RxNorm%' and concept_class_id = 'Ingredient' and standard_concept='S'
and concept_name like 'Lactobac%'
;
delete from dev_ingredient_stage where source_concept_name='lactic acid producing organisms' and concept_id is null;

insert into dev_ingredient_stage
SELECT distinct  'acid preparations','ATC','Ingredient','acid preparations',null, concept_id,concept_name,vocabulary_id
FROM devv5.concept_ancestor                                                      
JOIN concept c ON descendant_concept_id = c.concept_id
AND ancestor_concept_id IN (21600704)
AND vocabulary_id like 'RxNorm%' and concept_class_id = 'Ingredient' ;

delete from dev_ingredient_stage
where source_concept_name='acid preparations'
and concept_id is null;

insert into dev_ingredient_stage
SELECT distinct  'amino acids','ATC','Ingredient','amino acids',null, concept_id,concept_name,vocabulary_id	FROM devv5.concept_ancestor  -- antibiotic agents
JOIN concept c ON descendant_concept_id = c.concept_id
AND ancestor_concept_id IN (21601215, 21601034)
AND vocabulary_id like 'RxNorm%' and concept_class_id = 'Ingredient' ;

delete from dev_ingredient_stage
where source_concept_name='amino acids'
and concept_id is null;

insert into dev_ingredient_stage
SELECT distinct  'analgesics','ATC','Ingredient','analgesics',null, concept_id,concept_name,vocabulary_id
FROM devv5.concept_ancestor  -- antibiotic agents
JOIN concept c ON descendant_concept_id = c.concept_id
AND ancestor_concept_id IN (21604253)
AND vocabulary_id like 'RxNorm%' and concept_class_id = 'Ingredient'
and concept_id not in (939506, 950435, 964407 );

delete from dev_ingredient_stage
where source_concept_name='analgesics'
and concept_id is null;

delete from dev_ingredient_stage
where source_concept_name='antiinfectives'
and concept_id is null;

insert into dev_ingredient_stage
SELECT distinct 'cadmium compounds','ATC','Ingredient','cadmium compounds',null, concept_id,concept_name,vocabulary_id
from concept
where lower(concept_name) like '%cadmium %'
and concept_class_id = 'Ingredient'
and vocabulary_id like 'RxNorm%'
and concept_id not in (45775350);

delete from dev_ingredient_stage
where source_concept_name='cadmium compounds'
and concept_id is null;

insert into dev_ingredient_stage
SELECT distinct 'calcium (different salts)','ATC','Ingredient','calcium (different salts)',null, concept_id,concept_name,vocabulary_id
from concept
where lower(concept_name) like '%calcium %'
and concept_class_id = 'Ingredient'
and vocabulary_id like 'RxNorm%'
and concept_id not in (42903945, 43533002, 1337191, 19007595, 43532262, 19051475);

delete from dev_ingredient_stage
where source_concept_name='calcium (different salts)'
and concept_id is null;

insert into dev_ingredient_stage
SELECT distinct 'calcium compounds','ATC','Ingredient','calcium compounds',null, concept_id,concept_name,vocabulary_id
from concept
where lower(concept_name) like '%calcium %'
and concept_class_id = 'Ingredient'
and vocabulary_id like 'RxNorm%'
and concept_id not in (19014944, 42903945);

delete from dev_ingredient_stage
where source_concept_name='calcium compounds'
and concept_id is null;

insert into dev_ingredient_stage
SELECT distinct  'contact laxatives','ATC','Ingredient','contact laxatives',null, concept_id,concept_name,vocabulary_id
FROM devv5.concept_ancestor  
JOIN concept c ON descendant_concept_id = c.concept_id
AND ancestor_concept_id IN (21600537)
AND vocabulary_id like 'RxNorm%' and concept_class_id = 'Ingredient'
;

delete from dev_ingredient_stage
where source_concept_name='contact laxatives'
and concept_id is null;

insert into dev_ingredient_stage
SELECT distinct  'corticosteroids','ATC','Ingredient','corticosteroids',null, concept_id,concept_name,vocabulary_id
FROM devv5.concept_ancestor  
JOIN concept c ON descendant_concept_id = c.concept_id
AND ancestor_concept_id IN (21605042, 21605164, 21605200, 21605165, 21605199, 21601607)
AND vocabulary_id like 'RxNorm%' and concept_class_id = 'Ingredient'
;
delete from dev_ingredient_stage
where source_concept_name='corticosteroids'
and concept_id is null;

insert into dev_ingredient_stage
SELECT distinct  'cough suppressants','ATC','Ingredient','cough suppressants',null, concept_id,concept_name,vocabulary_id
FROM devv5.concept_ancestor  
JOIN concept c ON descendant_concept_id = c.concept_id
AND ancestor_concept_id IN (21603440, 21603366, 21603409, 21603395, 21603436)
AND vocabulary_id like 'RxNorm%' and concept_class_id = 'Ingredient'
and concept_id not in (943191, 1139042, 1189220, 1781321, 19008366, 19039512, 19041843, 19050346, 19058933, 19071861, 19088167, 19095266, 42904041 )
;
delete from dev_ingredient_stage
where source_concept_name='cough suppressants'
and concept_id is null;

insert into dev_ingredient_stage
SELECT distinct  'diuretics','ATC','Ingredient','diuretics',null, concept_id,concept_name,vocabulary_id
FROM devv5.concept_ancestor  s
JOIN concept c ON descendant_concept_id = c.concept_id
AND ancestor_concept_id IN (21601461)
AND vocabulary_id like 'RxNorm%' and concept_class_id = 'Ingredient';

delete from dev_ingredient_stage
where source_concept_name='diuretics'
and concept_id is null;

insert into dev_ingredient_stage
SELECT distinct  'magnesium (different salts)','ATC','Ingredient','magnesium (different salts)',null, concept_id,concept_name,vocabulary_id
FROM devv5.concept_ancestor  s
JOIN concept c ON descendant_concept_id = c.concept_id
AND ancestor_concept_id IN (21600892)
AND vocabulary_id like 'RxNorm%' and concept_class_id = 'Ingredient';

delete from dev_ingredient_stage
where source_concept_name='magnesium (different salts)'

insert into dev_ingredient_stage
SELECT distinct  'opium alkaloids with morphine','ATC','Ingredient','opium alkaloids with morphine',null, concept_id,concept_name,vocabulary_id
FROM devv5.concept_ancestor  s
JOIN concept c ON descendant_concept_id = c.concept_id
AND ancestor_concept_id IN (21604255)
AND vocabulary_id like 'RxNorm%' and concept_class_id = 'Ingredient'
and concept_id not in (19112635);

delete from dev_ingredient_stage
where source_concept_name='opium alkaloids with morphine'
and concept_id is null;

insert into dev_ingredient_stage
SELECT distinct  'opium derivatives','ATC','Ingredient','opium derivatives',null, concept_id,concept_name,vocabulary_id
FROM devv5.concept_ancestor  s
JOIN concept c ON descendant_concept_id = c.concept_id
AND ancestor_concept_id IN (21603396)
AND vocabulary_id like 'RxNorm%' and concept_class_id = 'Ingredient'
and concept_id not in (19021930, 1201620);

delete from dev_ingredient_stage
where source_concept_name='opium derivatives'
and concept_id is null;

insert into dev_ingredient_stage
SELECT distinct  'organic nitrates','ATC','Ingredient','organic nitrates',null, concept_id,concept_name,vocabulary_id
FROM devv5.concept_ancestor  s
JOIN concept c ON descendant_concept_id = c.concept_id
AND ancestor_concept_id IN (21600316)
AND vocabulary_id like 'RxNorm%' and concept_class_id = 'Ingredient' ;

delete from dev_ingredient_stage
where source_concept_name='organic nitrates'
and concept_id is null;

insert into dev_ingredient_stage
SELECT distinct  'psycholeptics','ATC','Ingredient','psycholeptics',null, concept_id,concept_name,vocabulary_id
FROM devv5.concept_ancestor  s
JOIN concept c ON descendant_concept_id = c.concept_id
AND ancestor_concept_id IN (21604489)
AND vocabulary_id like 'RxNorm%' and concept_class_id = 'Ingredient'
and concept_id not in (742594);

delete from dev_ingredient_stage
where source_concept_name='psycholeptics'
and concept_id is null;

insert into dev_ingredient_stage
SELECT distinct  'selenium compounds','ATC','Ingredient','selenium compounds',null, concept_id,concept_name,vocabulary_id
FROM devv5.concept_ancestor  s
JOIN concept c ON descendant_concept_id = c.concept_id
AND ancestor_concept_id IN (21600908)
AND vocabulary_id like 'RxNorm%' and concept_class_id = 'Ingredient';

delete from dev_ingredient_stage
where source_concept_name='selenium compounds'
and concept_id is null;

insert into dev_ingredient_stage
SELECT distinct  'silver compounds','ATC','Ingredient','silver compounds',null, concept_id,concept_name,vocabulary_id
FROM devv5.concept_ancestor  s
JOIN concept c ON descendant_concept_id = c.concept_id
AND ancestor_concept_id IN (21602248)
AND vocabulary_id like 'RxNorm%' and concept_class_id = 'Ingredient';

delete from dev_ingredient_stage
where source_concept_name='silver compounds'
and concept_id is null;

insert into dev_ingredient_stage
SELECT distinct  'sulfonylureas','ATC','Ingredient','sulfonylureas',null, concept_id,concept_name,vocabulary_id
FROM devv5.concept_ancestor  s
JOIN concept c ON descendant_concept_id = c.concept_id
AND ancestor_concept_id IN (21600749)
AND vocabulary_id like 'RxNorm%' and concept_class_id = 'Ingredient';

delete from dev_ingredient_stage
where source_concept_name='sulfonylureas'
and concept_id is null;

insert into dev_ingredient_stage
SELECT distinct  'antiinfectives','ATC','Ingredient','antiinfectives',null, concept_id,concept_name,vocabulary_id
FROM devv5.concept_ancestor  -- antibiotic agents
JOIN concept c ON descendant_concept_id = c.concept_id
AND ancestor_concept_id IN (40177425) 
AND vocabulary_id like 'RxNorm%' and concept_class_id = 'Ingredient' and concept_id not in (42800027,19010309,906914,967823,19077884,901656,40166605,19111620,1563600,917006,1552310,923540,975125,19089810,919681)
;
delete from dev_ingredient_stage where source_concept_name='antiinfectives' and concept_id is null;

insert into relationship_to_concept (concept_code_1,vocabulary_id_1,concept_id_2,precedence) 
select distinct source_concept_name,'ATC',concept_id, rank () over (partition by source_concept_name order by concept_id desc)
from dev_ingredient_stage
where concept_id is not null and (source_concept_name,concept_id) not in (select concept_code_1,concept_id_2 from relationship_to_concept) ;

-- COMBINATIONS EXCL. \\ WITH
create table dev_combo_stage as (
with primary_table as (
select *, split_part(atc_name, ',', 1) as ing from atc_1_comb
where atc_name ~ 'comb'
and atc_name ~ 'excl. psycholeptics'
and atc_name != 'combinations')
select atc_code, atc_name, adm_r, ing, 'ing' from primary_table);

insert into dev_combo_stage
select atc_code, atc_name, adm_r, concept_name, 'excl' from dev_combo_stage , dev_ingredient_stage
where source_concept_name = 'psycholeptics'
and atc_name ~ 'excl. psycholeptics';

insert into dev_combo_stage
select atc_code, atc_name, adm_r, split_part(atc_name, ',', 1) as ing, 'ing' from atc_1_comb a
left join reference using (atc_code)
where atc_name ~ 'excl|combinations of|derivate|other|with'
and atc_code not in (select atc_code from dev_combo_stage)
and atc_name ~ 'with psycholeptics';

insert into dev_combo_stage
select atc_code, atc_name, adm_r, concept_name, 'with' from dev_combo_stage , dev_ingredient_stage
where source_concept_name = 'psycholeptics'
and atc_name ~ 'with psycholeptics';


insert into dev_ingredient_stage
SELECT distinct  'proton pump inhibitors','ATC','Ingredient','proton pump inhibitors',null, concept_id,concept_name,vocabulary_id
FROM devv5.concept_ancestor  s
JOIN concept c ON descendant_concept_id = c.concept_id
AND ancestor_concept_id IN (21600095)
AND vocabulary_id like 'RxNorm%' and concept_class_id = 'Ingredient';

insert into dev_combo_stage
select atc_code, atc_name, adm_r, split_part(atc_name, ',', 1) as ing, 'ing' from atc_1_comb a
left join reference using (atc_code)
where atc_name ~ 'excl|combinations of|derivate|other|with'
and atc_code = 'B01AC56';

insert into dev_combo_stage
select atc_code, atc_name, adm_r, concept_name, 'with' from dev_combo_stage , dev_ingredient_stage
where source_concept_name = 'proton pump inhibitors'
and atc_code = 'B01AC56';

insert into dev_combo_stage
select atc_code, atc_name, adm_r, split_part(atc_name, ' and', 1) as ing, 'ing' from atc_1_comb a
left join reference using (atc_code)
where atc_name ~ 'excl|combinations of|derivate|other|with'
and atc_code = 'C07CB03';

insert into dev_combo_stage
select atc_code, atc_name, adm_r, concept_name, 'with' from dev_combo_stage , dev_ingredient_stage
where source_concept_name = 'diuretics'
and atc_code = 'C07CB03';

insert into dev_combo_stage
select atc_code, atc_name, adm_r, split_part(atc_name, ' and', 1) as ing, 'ing' from atc_1_comb a
left join reference using (atc_code)
where atc_name ~ 'excl|combinations of|derivate|other|with'
and atc_code = 'C07CB53';

insert into dev_combo_stage
select atc_code, atc_name, adm_r, concept_name, 'with' from dev_combo_stage , dev_ingredient_stage
where source_concept_name = 'diuretics'
and atc_code = 'C07CB53';

insert into dev_combo_stage
select atc_code, atc_name, adm_r, split_part(atc_name, ' and', 1) as ing, 'ing' from atc_1_comb a
left join reference using (atc_code)
where atc_name ~ 'excl|combinations of|derivate|other|with'
and atc_code = 'C07CA17';

insert into dev_combo_stage
select atc_code, atc_name, adm_r, concept_name, 'with' from dev_combo_stage , dev_ingredient_stage
where source_concept_name = 'diuretics'
and atc_code = 'C07CA17';

insert into dev_combo_stage
select atc_code, atc_name, adm_r, split_part(atc_name, ' in', 1) as ing, 'ing' from atc_1_comb a
where atc_name ~ 'excl|combinations of|derivate|other|with'
and atc_code = 'S01AA20';

insert into dev_combo_stage
select atc_code, atc_name, adm_r, split_part(atc_name, ' and', 1) as ing, 'ing' from atc_1_comb a
where atc_name ~ 'excl|combinations of|derivate|other|with'
and atc_code = 'S01XA20';

insert into dev_combo_stage
select atc_code, atc_name, adm_r, split_part(atc_name, ',', 1) as ing, 'ing' from atc_1_comb a
where atc_name ~ 'excl|combinations of|derivate|other|with'
and atc_code = 'C07DB01';

insert into dev_combo_stage
select atc_code, atc_name, adm_r, concept_name, 'with' from dev_combo_stage , dev_ingredient_stage
where source_concept_name = 'thiazides'
and atc_code = 'C07DB01';

insert into dev_combo_stage
select distinct atc_code, atc_name, adm_r, concept_name, 'with' from dev_combo_stage , dev_ingredient_stage
where source_concept_name = 'diuretics'
and atc_code = 'C07DB01'
and concept_name not in (select concept_name from dev_ingredient_stage
where source_concept_name = 'thiazides');

insert into dev_combo_stage
select atc_code, atc_name, adm_r, split_part(atc_name, 'in', 1) , 'ing' from atc_1_comb a
where atc_name ~ 'excl|combinations of|derivate|other|with'
and atc_code = 'N05CB02';

insert into dev_combo_stage
select atc_code, atc_name, adm_r, split_part(atc_name, ',', 1) , 'ing' from atc_1_comb a
where atc_name ~ 'excl|combinations of|derivate|other|with'
and atc_code = 'J07AE51';

insert into dev_combo_stage
select atc_code, atc_name, adm_r, split_part(atc_name, 'with ', 2), 'with' from dev_combo_stage
where atc_code = 'J07AE51';

insert into dev_combo_stage
select atc_code, atc_name, adm_r, split_part(atc_name, ' and', 1) , 'ing' from atc_1_comb a
where atc_name ~ 'excl|combinations of|derivate|other|with'
and atc_code = 'C02LC51';

insert into dev_combo_stage
select atc_code, atc_name, adm_r, concept_name, 'with' from dev_combo_stage , dev_ingredient_stage
where source_concept_name = 'diuretics'
and atc_code = 'C02LC51';

insert into dev_combo_stage
select atc_code, atc_name, adm_r, split_part(atc_name, ' and', 1) , 'ing' from atc_1_comb a
where atc_name ~ 'excl|combinations of|derivate|other|with'
and atc_code = 'N02AJ09';

insert into dev_combo_stage
select atc_code, atc_name, adm_r, split_part(atc_name, 'other ', 2) , 'with' from atc_1_comb a
where atc_name ~ 'excl|combinations of|derivate|other|with'
and atc_code = 'N02AJ09';

update  dev_combo_stage
set ing = 'carbasalate calcium'
where ing = 'carbasalate calcium combinations excl. psycholeptics';

-- G02BA03; G02BA02 change form to IUD
delete from reference where atc_code in ('G02BA03','G02BA02');
insert into reference
 values ('G02BA03','G02BA03 Intrauterine System');
insert into reference
 values ('G02BA02','G02BA02 Intrauterine System')

delete from internal_relationship_stage where concept_code_1 like 'G02BA0%';
insert into internal_relationship_stage
    values ('G02BA02 Intrauterine System','Intrauterine System');
insert into internal_relationship_stage
    values ('G02BA02 Intrauterine System','copper');
insert into internal_relationship_stage
    values ('G02BA03 Intrauterine System','Intrauterine System');
insert into internal_relationship_stage
    values ('G02BA03 Intrauterine System','progestogen');

delete from dev_combo_stage
where ing in ('organic nitrates in combination with psycholeptics','reserpine and diuretics');

insert into dev_combo_stage
select 'C01DA70', 'organic nitrates in combination with psycholeptics',concept_name,'ing'
 from dev_ingredient_stage where 
source_concept_name in ('organic nitrates');

insert into dev_combo_stage
select 'C01DA70', 'organic nitrates in combination with psycholeptics',concept_name,'with'
 from dev_ingredient_stage where 
source_concept_name in ('psycholeptics');

insert into dev_combo_stage
select 'C01DA70', 'organic nitrates in combination with psycholeptics',concept_name,'with'
 from dev_ingredient_stage where 
source_concept_name in ('psycholeptics');

insert into dev_combo_stage
select 'C02LA71', 'reserpine and diuretics, combinations with psycholeptics','reserpine','ing'
;
insert into dev_combo_stage
select 'C02LA71', 'reserpine and diuretics, combinations with psycholeptics',concept_name,'with'
 from dev_ingredient_stage where 
source_concept_name in ('diuretics');

