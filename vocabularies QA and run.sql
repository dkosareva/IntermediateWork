select CURRENT_USER;
show search_path;


--Create_DEV_from_DevV5_DDL
--https://github.com/OHDSI/Vocabulary-v5.0/blob/master/working/Create_DEV_from_DevV5_DDL.sql



--Fast recreate;
--Use this script to recreate main tables (concept, concept_relationship, concept_synonym etc) without dropping your schema
--devv5 - static variable;

--recreate with default settings (copy from devv5, w/o ancestor, deprecated relationships and synonyms (faster)
SELECT devv5.FastRecreateSchema(main_schema_name=>'devv5');

--same as above, but table concept_ancestor is included
SELECT devv5.FastRecreateSchema(main_schema_name=>'devv5', include_concept_ancestor=>true);

--full recreate, all tables are included (much slower)
SELECT devv5.FastRecreateSchema(main_schema_name=>'devv5', include_concept_ancestor=>true, include_deprecated_rels=>true, include_synonyms=>true);

--preserve old concept_ancestor, but it will be ignored if the include_concept_ancestor is set to true
SELECT devv5.FastRecreateSchema(main_schema_name=>'devv5', drop_concept_ancestor=>false);

SELECT devv5.FastRecreateSchema(main_schema_name=>'devv5', include_synonyms=>true);





--stage tables checks
--RUN all queries from Vocabulary-v5.0/working/QA_stage_tables.sql
--All queries should retrieve NULL



--DRUG stage tables checks
--RUN all queries from Vocabulary-v5.0/working/drug_stage_tables_QA.sql --All queries should retrieve NULL
--RUN all queries from Vocabulary-v5.0/working/Drug_stage_QA_optional.sql --All queries should retrieve NULL, but see comment inside



--for DRUG vocab (if creating RxE for them)
--Run Build_RxE script. Comment last “drops” block if you plan on using MapDrugVocab.
--If the source vocabulary does not fulfill quality criteria for RxE, run
-- script.




--GenericUpdate; devv5 - static variable
DO $_$
BEGIN
	PERFORM devv5.GenericUpdate();
END $_$;


--basic tables checks
--RUN all queries from Vocabulary-v5.0/working/CreateNewVocabulary_QA.sql --All queries should retrieve NULL


--DRUG basic tables checks
--RUN all queries from Vocabulary-v5.working/Basic_tables_QA.sql --All queries should retrieve NULL


--QA checks
--should retrieve NULL
select * from QA_TESTS.GET_CHECKS();




--manual ConceptAncestor (needed vocabularies are to be specified)
 DO $_$
 BEGIN
    PERFORM VOCABULARY_PACK.pManualConceptAncestor(
    pVocabularies => 'SNOMED,LOINC'
 );
 END $_$
;




--get_summary - changes in tables between dev-schema (current) and devv5/prodv5/any other schema
--supported tables: concept, concept_relationship, concept_ancestor

--first clean cache
select * from qa_tests.purge_cache();


--summary (table to check, schema to compare)
select * from qa_tests.get_summary (table_name=>'concept',pCompareWith=>'devv5');


--summary (table to check, schema to compare)
select * from qa_tests.get_summary (table_name=>'concept_relationship',pCompareWith=>'devv5');

--summary (table to check, schema to compare)
select * from qa_tests.get_summary (table_name=>'concept_ancestor',pCompareWith=>'devv5');




--Statistics QA checks
--changes in tables between dev-schema (current) and devv5/prodv5/any other schema
select * from qa_tests.get_domain_changes(pCompareWith=>'devv5'); --Domain changes
select * from qa_tests.get_newly_concepts(pCompareWith=>'devv5'); --Newly added concepts grouped by vocabulary_id and domain
select * from qa_tests.get_standard_concept_changes(pCompareWith=>'devv5'); --Standard concept changes
select * from qa_tests.get_newly_concepts_standard_concept_status(pCompareWith=>'devv5'); --Newly added concepts and their standard concept status
select * from qa_tests.get_changes_concept_mapping(pCompareWith=>'devv5'); --Changes of concept mapping status grouped by target domain







--check first vacant concept_id for manual change
SELECT MAX (concept_id) + 1 FROM devv5.concept WHERE concept_id >= 31967 AND concept_id < 72245;


--check first vacant concept_code among OMOP generated
select 'OMOP'||max(replace(concept_code, 'OMOP','')::int4)+1 from devv5.concept where concept_code like 'OMOP%'  and concept_code not like '% %';


--create sequence starting from first vacant concept_code among OMOP generated
DO $$
DECLARE
	ex INTEGER;
BEGIN
	SELECT MAX(REPLACE(concept_code, 'OMOP','')::int4)+1 INTO ex FROM (
		SELECT concept_code FROM concept WHERE concept_code LIKE 'OMOP%'  AND concept_code NOT LIKE '% %' -- Last valid value of the OMOP123-type codes
			) AS s0;
	DROP SEQUENCE IF EXISTS omop_seq;
	EXECUTE 'CREATE SEQUENCE omop_seq INCREMENT BY 1 START WITH ' || ex || ' NO CYCLE CACHE 20';
END$$;