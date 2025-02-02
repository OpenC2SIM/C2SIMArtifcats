<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:map="http://www.w3.org/2005/xpath-functions/map" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:err="http://www.w3.org/2005/xqt-errors" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" exclude-result-prefixes="array fn map math owl rdf rdfs xhtml xs err" version="3.0">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!-- This XSLT operates on ontology file(s) forming the the Simulation Interoperability Standards Organization (SISO) Command and Control System to Simulation System 
          Interoperation (C2SIM) standard to create an XML schema file for use in implementation of the standard. The input file must be in rdf/xml format as generated from
          source ontology file(s) by the Protege ontology editing tool developed and maintained by Stanford University (http://protege.stanford.edu). 
	
	Version 1.0.0: initial version 
	
	Version 1.0.1 - 13/10/2021: correction in the transformation logic to handle issue about tactical graphics (classes without property restrictions), and addition of annotation information
	
	Version 1.0.2 - 13/09/2022: correction in the transformation logic to handle leaf classes without property restrictions, and addition of annotation information
	-->

    <!-- The following XSLT template is the starting point for processing, matching the root of the input file. -->
	<xsl:template match="/" name="xsl:initial-template">
		<!-- output the xs:schema root element and initial annotations in the generated XML schema document -->
		<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xml="http://www.w3.org/XML/1998/namespace" xmlns:vc="http://www.w3.org/2007/XMLSchema-versioning" xmlns="http://www.sisostds.org/schemas/C2SIM/1.1" targetNamespace="http://www.sisostds.org/schemas/C2SIM/1.1" elementFormDefault="qualified" attributeFormDefault="unqualified" vc:minVersion="1.1">
			<xsl:element name="xs:annotation">
				<xsl:element name="xs:documentation">
					<xsl:attribute name="xml:lang">
						<xsl:text>en</xsl:text>
					</xsl:attribute>
					<xsl:text>This C2SIM schema was generated by C2SIMOntologyToC2SIMSchemaV1.0.1.xslt from the following C2SIM ontologies: </xsl:text>
					<xsl:for-each select="rdf:RDF/owl:Ontology/owl:versionInfo">
						<xsl:value-of select="."/>
						<xsl:text> / </xsl:text>
					</xsl:for-each>
				</xsl:element>
			</xsl:element>
			
			<!-- parse the OWL datatypes to declare simple or complex types in the XMLL schema document -->
			<xsl:call-template name="SimpleTypesFromDatatypes"/>
			
			<!-- parse the OWL datatype properties to declare simple types in the XML schema document -->
			<xsl:call-template name="SimpleTypesFromDataProperties"/>
			
			<!-- parse the OWL object properties to declare elements in the XML schema document whose types are derived from class definitions -->
			<xsl:call-template name="ElementsFromObjectProperties"/>
			
			<!-- parse OWL class structures to create complex types and define elements of those types in the XML schema document -->
			<xsl:call-template name="ComplexTypesFromClassStructures"/>
			
		</xs:schema>

	</xsl:template>
	
	<!-- this template parses OWL datatypes to declare simple types in the XML schema document  -->
	<xsl:template name="SimpleTypesFromDatatypes">
		<xsl:element name="xs:annotation">
			<xsl:element name="xs:documentation">
				<xsl:attribute name="xml:lang">
					<xsl:text>en</xsl:text>
				</xsl:attribute>
				<xsl:text>***********************************************************</xsl:text>
				<xsl:text>****** SIMPLE TYPES DERIVED FROM ONTOLOGY DATA TYPES ******</xsl:text>
				<xsl:text>***********************************************************</xsl:text>
			</xsl:element>
		</xsl:element>
		<xsl:for-each select="rdf:RDF/rdfs:Datatype">
			<xsl:element name="xs:simpleType">
				<xsl:attribute name="name">
					<xsl:value-of select="fn:concat(fn:substring-after(./@rdf:about, '#'), 'Type')"/>
				</xsl:attribute>
				<!-- if there is rdfs:comment information, add it as an annotation element in the schema -->
				<xsl:call-template name="AddAnnotationInformation">
					<xsl:with-param name="ontologyComponent" select="."/>
				</xsl:call-template>
				<xsl:choose>
					<xsl:when test="./owl:equivalentClass/rdfs:Datatype/owl:onDatatype">
						<!-- need to restrict some datatype -->
						<xsl:element name="xs:restriction">
							<xsl:attribute name="base">
								<xsl:text>xs:</xsl:text>
								<xsl:value-of select="fn:substring-after(./owl:equivalentClass/rdfs:Datatype/owl:onDatatype/@rdf:resource, '#')"/>
							</xsl:attribute>
							<!-- look for different kinds of restrictions on a base class to output as facets on the simple type -->
							<xsl:if test="./owl:equivalentClass/rdfs:Datatype/owl:withRestrictions/rdf:Description/xsd:pattern">
									<xsl:element name="xs:pattern">
										<xsl:attribute name="value">
											<xsl:value-of select="./owl:equivalentClass/rdfs:Datatype/owl:withRestrictions/rdf:Description/xsd:pattern"/>
										</xsl:attribute>
									</xsl:element>
							</xsl:if>
							<xsl:if test="./owl:equivalentClass/rdfs:Datatype/owl:withRestrictions/rdf:Description/xsd:minInclusive">
								<xsl:element name="xs:minInclusive">
									<xsl:attribute name="value">
										<xsl:value-of select="./owl:equivalentClass/rdfs:Datatype/owl:withRestrictions/rdf:Description/xsd:minInclusive"/>
									</xsl:attribute>
								</xsl:element>
							</xsl:if>
							<xsl:if test="./owl:equivalentClass/rdfs:Datatype/owl:withRestrictions/rdf:Description/xsd:minExclusive">
								<xsl:element name="xs:minExclusive">
									<xsl:attribute name="value">
										<xsl:value-of select="./owl:equivalentClass/rdfs:Datatype/owl:withRestrictions/rdf:Description/xsd:minExclusive"/>
									</xsl:attribute>
								</xsl:element>
							</xsl:if>
							<xsl:if test="./owl:equivalentClass/rdfs:Datatype/owl:withRestrictions/rdf:Description/xsd:maxInclusive">
								<xsl:element name="xs:maxInclusive">
									<xsl:attribute name="value">
										<xsl:value-of select="./owl:equivalentClass/rdfs:Datatype/owl:withRestrictions/rdf:Description/xsd:maxInclusive"/>
									</xsl:attribute>
								</xsl:element>
							</xsl:if>
							<xsl:if test="./owl:equivalentClass/rdfs:Datatype/owl:withRestrictions/rdf:Description/xsd:maxExclusive">
								<xsl:element name="xs:maxExclusive">
									<xsl:attribute name="value">
										<xsl:value-of select="./owl:equivalentClass/rdfs:Datatype/owl:withRestrictions/rdf:Description/xsd:maxExclusive"/>
									</xsl:attribute>
								</xsl:element>
							</xsl:if>
						</xsl:element>
					</xsl:when>
					<xsl:otherwise>
						<!-- no named datatype restriction, so restrict xs:string -->
						<xsl:element name="xs:restriction">
							<xsl:attribute name="base">
								<xsl:text>xs:string</xsl:text>
							</xsl:attribute>
						</xsl:element>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>
	
	<!-- this template parses the OWL datatype properties to declare simple types in the XML schema document -->
	<xsl:template name="SimpleTypesFromDataProperties">
		<xsl:element name="xs:annotation">
			<xsl:element name="xs:documentation">
				<xsl:attribute name="xml:lang">
					<xsl:text>en</xsl:text>
				</xsl:attribute>
				<xsl:text>****************************************************************</xsl:text>
				<xsl:text>****** SIMPLE TYPES DERIVED FROM ONTOLOGY DATA PROPERTIES ******</xsl:text>
				<xsl:text>****************************************************************</xsl:text>
			</xsl:element>
		</xsl:element>
		<xsl:for-each select="rdf:RDF/owl:DatatypeProperty">
			<xsl:variable name="typeNamePrefix" select="fn:substring-after(./@rdf:about, '#')"/>
			<!-- simple case: property has no parent property -->
			<xsl:choose>
				<xsl:when test="fn:count(./rdfs:subPropertyOf) = 0">
					<xsl:element name="xs:simpleType">
						<xsl:attribute name="name">
							<xsl:call-template name="RemovePrefixOnPropertyName">
								<xsl:with-param name="propertyNameString" select="fn:concat($typeNamePrefix, 'Type')"/>
							</xsl:call-template>
						</xsl:attribute>
						<!-- if there is rdfs:comment information, add it as an annotation element in the schema -->
						<xsl:call-template name="AddAnnotationInformation">
							<xsl:with-param name="ontologyComponent" select="."/>
						</xsl:call-template>
						<!-- look for various restrictions on the property -->
						<xsl:choose>
							<xsl:when test="./rdfs:range">
								<!-- use the range as the type -->
								<xsl:element name="xs:restriction">
									<xsl:attribute name="base">
										<xsl:choose>
											<xsl:when test="fn:contains(./rdfs:range/@rdf:resource, 'XMLSchema')">
												<xsl:value-of select="fn:concat('xs:', fn:substring-after(./rdfs:range/@rdf:resource, '#'))"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="fn:concat(fn:substring-after(./rdfs:range/@rdf:resource, '#'), 'Type')"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:attribute>
								</xsl:element>
							</xsl:when>
							<xsl:otherwise>
								<xsl:element name="xs:restriction">
									<xsl:attribute name="base">
										<xsl:text>xs:string</xsl:text>
									</xsl:attribute>
								</xsl:element>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
				</xsl:when>
				<xsl:when test="./rdfs:subPropertyOf">
					<!-- the property is declared as a subproperty of another property -->
					<xsl:element name="xs:simpleType">
						<xsl:attribute name="name">
							<xsl:call-template name="RemovePrefixOnPropertyName">
								<xsl:with-param name="propertyNameString" select="fn:concat($typeNamePrefix, 'Type')"/>
							</xsl:call-template>
						</xsl:attribute>
						<!-- if there is rdfs:comment information, add it as an annotation element in the schema -->
						<xsl:call-template name="AddAnnotationInformation">
							<xsl:with-param name="ontologyComponent" select="."/>
						</xsl:call-template>
						<!-- look for various restrictions on the property -->
						<!-- recurse through the parent properties until a range is reached or the chain of parent properties ends without a range specified -->
						<xsl:call-template name="FindParentDataPropertyRange">
							<xsl:with-param name="startingProperty" select="."/>
						</xsl:call-template>
					</xsl:element>
				</xsl:when>
			</xsl:choose>
			<!-- also declare an element of that type for reference elsewhere -->
			<xsl:element name="xs:element">
				<xsl:attribute name="name">
					<xsl:call-template name="RemovePrefixOnPropertyName">
						<xsl:with-param name="propertyNameString" select="$typeNamePrefix"/>
					</xsl:call-template>
				</xsl:attribute>
				<xsl:attribute name="type">
					<xsl:call-template name="RemovePrefixOnPropertyName">
						<xsl:with-param name="propertyNameString" select="fn:concat($typeNamePrefix, 'Type')"/>
					</xsl:call-template>
				</xsl:attribute>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>
	
	<!-- this template parses the OWL object properties to declare elements in the XML schema document whose types are derived from class definitions -->
	<xsl:template name="ElementsFromObjectProperties">
		<xsl:element name="xs:annotation">
			<xsl:element name="xs:documentation">
				<xsl:attribute name="xml:lang">
					<xsl:text>en</xsl:text>
				</xsl:attribute>
				<xsl:text>**************************************************************</xsl:text>
				<xsl:text>****** ELEMENTS DERIVED FROM ONTOLOGY OBJECT PROPERTIES ******</xsl:text>
				<xsl:text>**************************************************************</xsl:text>
			</xsl:element>
		</xsl:element>
		<xsl:for-each select="rdf:RDF/owl:ObjectProperty">
			<xsl:variable name="typeNamePrefix" select="fn:substring-after(./@rdf:about, '#')"/>
			<xsl:choose>
				<!-- simple case: property has no parent property -->
				<xsl:when test="fn:count(./rdfs:subPropertyOf) = 0">
					<xsl:element name="xs:element">
						<xsl:attribute name="name">
							<xsl:call-template name="RemovePrefixOnPropertyName">
								<xsl:with-param name="propertyNameString" select="$typeNamePrefix"/>
							</xsl:call-template>
						</xsl:attribute>
						<!-- look for various restrictions on the property -->
						<xsl:choose>
							<xsl:when test="./rdfs:range">
								<!-- use the range as the type -->
								<xsl:attribute name="type">
									<xsl:choose>
										<xsl:when test="fn:contains(./rdfs:range/@rdf:resource, 'XMLSchema')">
											<xsl:value-of select="fn:concat('xs:', fn:substring-after(./rdfs:range/@rdf:resource, '#'))"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:call-template name="RemovePrefixOnPropertyName">
												<xsl:with-param name="propertyNameString" select="fn:concat(fn:substring-after(./rdfs:range/@rdf:resource, '#'), 'Type')"/>
											</xsl:call-template>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="type">
									<xsl:text>xs:string</xsl:text>
								</xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>
						<!-- if there is rdfs:comment information, add it as an annotation element in the schema -->
						<xsl:call-template name="AddAnnotationInformation">
							<xsl:with-param name="ontologyComponent" select="."/>
						</xsl:call-template>
					</xsl:element>
				</xsl:when>
				<xsl:when test="./rdfs:subPropertyOf">
					<!-- the property is declared as a subproperty of another property -->
					<xsl:element name="xs:element">
						<xsl:attribute name="name">
							<xsl:call-template name="RemovePrefixOnPropertyName">
								<xsl:with-param name="propertyNameString" select="$typeNamePrefix"/>
							</xsl:call-template>
						</xsl:attribute>
						<!-- look for various restrictions on the property -->
						<!-- recurse through the parent properties until a range is reached or the chain of parent properties ends without a range specified -->
						<xsl:call-template name="FindParentObjectPropertyRange">
							<xsl:with-param name="startingProperty" select="."/>
						</xsl:call-template>
						<!-- if there is rdfs:comment information, add it as an annotation element in the schema -->
						<xsl:call-template name="AddAnnotationInformation">
							<xsl:with-param name="ontologyComponent" select="."/>
						</xsl:call-template>
					</xsl:element>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
	
	<!-- this template parses OWL class structures to create complex types and define elements of those types in the XML schema document -->
	<xsl:template name="ComplexTypesFromClassStructures">
		<xsl:element name="xs:annotation">
			<xsl:element name="xs:documentation">
				<xsl:attribute name="xml:lang">
					<xsl:text>en</xsl:text>
				</xsl:attribute>
				<xsl:text>***************************************************************************</xsl:text>
				<xsl:text>****** COMPLEX TYPES AND MODEL GROUPS DERIVED FROM ONTOLOGY CLASSES ******</xsl:text>
				<xsl:text>***************************************************************************</xsl:text>
			</xsl:element>
		</xsl:element>
		<!-- for each class structure, need to recurse through any subclasses (or start with subclasses) -->
		<xsl:for-each select="rdf:RDF/owl:Class">
			<xsl:variable name="classNameString" select="./@rdf:about"/>
			<xsl:variable name="thisClassName" select="fn:substring-after($classNameString,'#')"/>
			<!-- there are certain patterns to look for in the ontology -->
			<!-- (1) if the class has named individuals, consider it to be an enumeration class -->
			<!-- (2) subclassOf property restriction axioms with/without properties derived from parent class(es) -->
			<!-- (3) class has subclasses (create xs:choice structure) -->
			<xsl:choose>
				<!-- see if the class has NamedIndividuals; if so, generate an enumeration simple type -->
				<xsl:when test="../owl:NamedIndividual/rdf:type[@rdf:resource=$classNameString]">
					<xsl:call-template name="GenerateEnumerationType">
						<xsl:with-param name="enumClass" select="."/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<!-- all other class structures -->
					<!-- see if any of this class's superclasses have property axioms -->
					<xsl:variable name="hasSuperclassWithPropAxioms">
						<xsl:call-template name="CheckForSuperclassProperties">
							<xsl:with-param name="classNode" select="."/>
						</xsl:call-template>
					</xsl:variable>
					<!-- Global description of code logic:
					   IF (class has one or more subclasses)  
					        IF (the class contains some owl:Restriction)
					             call GenerateModelGroup (includes also CreateChoiceOfSubclasses)
					        ELSE
					             call CreateChoiceOfSubclasses
					        END IF 
					   ELSE IF (class has NOT superclasses with property axioms)  
					        create an empty complex type and its element 
					   ELSE 
					        call ExamineSubclassNodeSet
					   END IF 
					-->
					<xsl:choose>
						<xsl:when test="fn:count(/rdf:RDF/owl:Class[rdfs:subClassOf/@rdf:resource = $classNameString]) > 0">
							<xsl:choose>
								<!-- if the superclass has property axioms -->
								<xsl:when test="./rdfs:subClassOf/owl:Restriction">
									<xsl:call-template name="GenerateModelGroup"/>
								</xsl:when>
								<xsl:otherwise>
									<!-- the class has one or more subclasses -->
									<xsl:call-template name="CreateChoiceOfSubclasses">
										<xsl:with-param name="className" select="$classNameString"/>
										<xsl:with-param name="subclassNodeList" select="/rdf:RDF/owl:Class[rdfs:subClassOf/@rdf:resource = $classNameString]"/>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="fn:contains($hasSuperclassWithPropAxioms, 'failure')">
									<!-- class has no inherited properties, no properties of its own, and no subclasses, so create an empty type with its element -->
									<xsl:element name="xs:complexType">
										<xsl:attribute name="name">
											<xsl:value-of select="fn:concat($thisClassName, 'Type')"/>
										</xsl:attribute>
										<!-- if there is rdfs:comment information, add it as an annotation element in the schema -->
										<xsl:call-template name="AddAnnotationInformation">
											<xsl:with-param name="ontologyComponent" select="."/>
										</xsl:call-template>
									</xsl:element>
									<!-- also declare an element of that type for reference elsewhere -->
									<xsl:element name="xs:element">
										<xsl:attribute name="name">
											<xsl:call-template name="RemovePrefixOnPropertyName">
												<xsl:with-param name="propertyNameString" select="$thisClassName"/>
											</xsl:call-template>
										</xsl:attribute>
										<xsl:attribute name="type">
											<xsl:call-template name="RemovePrefixOnPropertyName">
												<xsl:with-param name="propertyNameString" select="fn:concat($thisClassName, 'Type')"/>
											</xsl:call-template>
										</xsl:attribute>
									</xsl:element>
								</xsl:when>
								<xsl:otherwise>
									<!-- class has superclasses with property axioms -->
									<xsl:call-template name="ExamineSubclassNodeSet">
										<xsl:with-param name="subClassNodeSet" select="/rdf:RDF/owl:Class[rdfs:subClassOf/@rdf:resource = $classNameString]"/>
										<xsl:with-param name="classContextNode" select="."/>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>						
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	
	</xsl:template>
	
	<!-- ***** UTILITY TEMPLATES PROVIDING SUPPORTING LOGIC FOR THE MAIN TRANSFORMATION TEMPLATES ***** -->
	
	<!-- this template creates annotation/documentation structures in the generated XML schema from rdfs:comment assertions in the ontology  -->
	<xsl:template name="AddAnnotationInformation">
		<xsl:param name="ontologyComponent"/>
		<xsl:element name="xs:annotation">
			<!-- if there is rdfs:comment information, add it as an annotation element in the schema -->
			<xsl:if test="$ontologyComponent/rdfs:comment">
				<xsl:element name="xs:documentation">
					<xsl:value-of select="$ontologyComponent/rdfs:comment"/>
				</xsl:element>
			</xsl:if>
			<!-- check if there is some global rdf:Description, and add them as an annotation element in the schema -->
			<xsl:for-each select="/rdf:RDF/rdf:Description[@rdf:about=$ontologyComponent/@rdf:about]">
				<xsl:element name="xs:documentation">
					<xsl:value-of select="./rdfs:comment"/>
				</xsl:element>
			</xsl:for-each>
			<!-- create a documentation element to show the source ontology namespace for this concept -->
			<xsl:element name="xs:documentation">
				<xsl:value-of select="$ontologyComponent/@rdf:about"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<!-- this template creates enumeration types from named individuals in the class passed to the template  -->
	<xsl:template name="GenerateEnumerationType">
		<xsl:param name="enumClass"/>
		<xsl:element name="xs:simpleType">
			<xsl:attribute name="name">
				<xsl:value-of select="fn:concat(fn:substring-after($enumClass/@rdf:about,'#'), 'Type')"/>
			</xsl:attribute>
			<!-- if there is rdfs:comment information, add it as an annotation element in the schema -->
			<xsl:call-template name="AddAnnotationInformation">
				<xsl:with-param name="ontologyComponent" select="."/>
			</xsl:call-template>
			<xsl:element name="xs:restriction">
				<xsl:attribute name="base"><xsl:text>xs:string</xsl:text></xsl:attribute>
				<xsl:for-each select="/rdf:RDF/owl:NamedIndividual/rdf:type[@rdf:resource=$enumClass/@rdf:about]">
					<xsl:element name="xs:enumeration">
						<xsl:attribute name="value">
							<xsl:value-of select="fn:substring-after(../@rdf:about,'#')"/>
						</xsl:attribute>
					</xsl:element>
				</xsl:for-each>
			</xsl:element>
		</xsl:element>
		<!-- also generate an element of that type if the class was not used as a range in an object property -->
		<xsl:if test="fn:count(/rdf:RDF/owl:ObjectProperty/rdfs:range[@rdf:resource = $enumClass/@rdf:about]) = 0">
			<xsl:element name="xs:element">
				<xsl:attribute name="name">
					<xsl:value-of select="fn:substring-after($enumClass/@rdf:about,'#')"/>
				</xsl:attribute>
				<xsl:attribute name="type">
					<xsl:value-of select="fn:concat(fn:substring-after($enumClass/@rdf:about,'#'), 'Type')"/>
				</xsl:attribute>
			</xsl:element>
		</xsl:if>
	</xsl:template>

	<!-- this template creates element declarations in the schema from property axioms in class declarations in the ontology -->
	<xsl:template name="PropertySubclasses">
		<xsl:param name="className"/>
		<xsl:for-each select="$className/rdfs:subClassOf/owl:Restriction/owl:onProperty">
			<xsl:element name="xs:element">
				<xsl:attribute name="ref">
					<xsl:call-template name="RemovePrefixOnPropertyName">
						<xsl:with-param name="propertyNameString" select="fn:substring-after(./@rdf:resource,'#')"/>
					</xsl:call-template>
				</xsl:attribute>
				<xsl:call-template name="AddCardinalityAttributes">
					<xsl:with-param name="context" select=".."/>
				</xsl:call-template>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>
	
	<!-- this template extracts minOccurs and maxOccurs attribute values from cardinality restrictons on property axioms -->
	<xsl:template name="AddCardinalityAttributes">
		<xsl:param name="context"/>
		<xsl:if test="$context/owl:minQualifiedCardinality">
			<xsl:attribute name="minOccurs">
				<xsl:value-of select="$context/owl:minQualifiedCardinality"/>
			</xsl:attribute>
			<xsl:if test="not($context/owl:maxQualifiedCardinality)">
				<xsl:attribute name="maxOccurs">
					<xsl:text>unbounded</xsl:text>
				</xsl:attribute>
			</xsl:if>
		</xsl:if>
		<xsl:if test="$context/owl:maxQualifiedCardinality">
			<xsl:if test="not($context/owl:minQualifiedCardinality) and $context/owl:maxQualifiedCardinality = 1">
				<xsl:attribute name="minOccurs">
					<xsl:text>0</xsl:text>
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="maxOccurs">
				<xsl:value-of select="$context/owl:maxQualifiedCardinality"/>
			</xsl:attribute>
		</xsl:if>
		<xsl:if test="$context/owl:qualifiedCardinality">
			<xsl:attribute name="minOccurs">
				<xsl:value-of select="$context/owl:qualifiedCardinality"/>
			</xsl:attribute>
			<xsl:attribute name="maxOccurs">
				<xsl:value-of select="$context/owl:qualifiedCardinality"/>
			</xsl:attribute>
		</xsl:if>
		<xsl:if test="$context/owl:someValuesFrom">
			<xsl:attribute name="minOccurs">
				<xsl:text>1</xsl:text>
			</xsl:attribute>
			<xsl:attribute name="maxOccurs">
				<xsl:text>unbounded</xsl:text>
			</xsl:attribute>
		</xsl:if>
		<xsl:if test="$context/owl:allValuesFrom">
			<xsl:attribute name="minOccurs">
				<xsl:text>0</xsl:text>
			</xsl:attribute>
			<xsl:attribute name="maxOccurs">
				<xsl:text>unbounded</xsl:text>
			</xsl:attribute>
		</xsl:if>
	</xsl:template>
	
	<!-- this template recursively follows a chain of parent datatype properties until either a range restriction is found or the top-most parent property is found -->
	<xsl:template name="FindParentDataPropertyRange">
		<xsl:param name="startingProperty"/>
		<xsl:choose>
			<xsl:when test="$startingProperty/rdfs:range">
				<!-- use the range as the type -->
				<xsl:element name="xs:restriction">
					<xsl:attribute name="base">
						<xsl:variable name="rangeClassURI">
							<xsl:value-of select="$startingProperty/rdfs:range/@rdf:resource"/>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test="fn:contains($rangeClassURI, 'XMLSchema')">
								<xsl:value-of select="fn:concat('xs:', fn:substring-after($rangeClassURI, '#'))"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="fn:concat(fn:substring-after($startingProperty/rdfs:range/@rdf:resource, '#'), 'Type')"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
				</xsl:element>
			</xsl:when>
			<xsl:when test="$startingProperty/rdfs:subPropertyOf">
				<xsl:for-each select="/rdf:RDF/owl:DatatypeProperty[@rdf:about=$startingProperty/rdfs:subPropertyOf/@rdf:resource]">
					<xsl:call-template name="FindParentDataPropertyRange">
						<xsl:with-param name="startingProperty" select="."/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<!-- generate the type as a restriction on the top-level parent property -->
				<xsl:element name="xs:restriction">
					<xsl:attribute name="base">
						<xsl:value-of select="fn:concat(fn:substring-after($startingProperty/@rdf:about, '#'), 'Type')"/>
					</xsl:attribute>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- this template recursively follows a chain of parent object properties until either a range restriction is found or the top-most parent property is found -->
	<xsl:template name="FindParentObjectPropertyRange">
		<xsl:param name="startingProperty"/>
		<xsl:choose>
			<xsl:when test="$startingProperty/rdfs:range">
				<!-- use the range as the type -->
				<xsl:variable name="rangeClassName">
					<xsl:value-of select="$startingProperty/rdfs:range/@rdf:resource"/>
				</xsl:variable>
				<xsl:attribute name="type">
					<xsl:choose>
						<xsl:when test="fn:contains($rangeClassName, 'XMLSchema')">
							<xsl:value-of select="fn:concat('xs:', fn:substring-after($rangeClassName, '#'))"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="fn:concat(fn:substring-after($rangeClassName, '#'), 'Type')"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			</xsl:when>
			<xsl:when test="$startingProperty/rdfs:subPropertyOf">
				<xsl:for-each select="/rdf:RDF/owl:ObjectProperty[@rdf:about=$startingProperty/rdfs:subPropertyOf/@rdf:resource]">
					<xsl:call-template name="FindParentObjectPropertyRange">
						<xsl:with-param name="startingProperty" select="."/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<!-- generate the type as a restriction on the top-level parent property -->
				<xsl:attribute name="type">
					<xsl:value-of select="fn:concat(fn:substring-after($startingProperty/@rdf:about, '#'), 'Type')"/>
				</xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- this template removes certain string prefixes from the names of properties; the list must be updated when new prefixes are used in the source ontology file -->
	<xsl:template name="RemovePrefixOnPropertyName">
		<xsl:param name="propertyNameString"/>
		<xsl:choose>
			<xsl:when test="fn:starts-with($propertyNameString, 'has')">
				<xsl:value-of select="fn:substring-after($propertyNameString, 'has')"/>
			</xsl:when>
			<xsl:when test="fn:starts-with($propertyNameString, 'can')">
				<xsl:value-of select="fn:substring-after($propertyNameString, 'can')"/>
			</xsl:when>
			<xsl:when test="fn:starts-with($propertyNameString, 'is')">
				<xsl:value-of select="fn:substring-after($propertyNameString, 'is')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$propertyNameString"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- this template recursively examines subclasses of a class to determine if a model group needs to be generated in the XML schema document -->
	<xsl:template name="ExamineSubclassNodeSet">
		<xsl:param name="subClassNodeSet"/>
		<xsl:param name="classContextNode"/>
		<xsl:choose>
			<!-- case 1: node set is not empty (i.e., class in question has subclasses) -->
			<xsl:when test="$subClassNodeSet">
				<xsl:variable name="subclassNode" select="$subClassNodeSet[fn:position() = 1]"/>
				<xsl:variable name="classNameString" select="$subclassNode/@rdf:about"/>
				<xsl:choose>
					<!-- if the superclass has property axioms -->
					<xsl:when test="./rdfs:subClassOf/owl:Restriction">
						<xsl:call-template name="GenerateModelGroup"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="ExamineSubclassNodeSet">
							<xsl:with-param name="subClassNodeSet" select="$subClassNodeSet[fn:position() != 1]"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<!-- all other cases -->
			<xsl:otherwise>
				<!-- looked through all the subclasses without finding any with property axioms, so create a complex type for the subject class -->
				<xsl:call-template name="GenerateComplexType">
					<xsl:with-param name="classContext" select="$classContextNode"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- this template generates a named model group for property axioms in a class that is defined by property axioms and has subclasses -->
	<xsl:template name="GenerateModelGroup">
		<xsl:element name="xs:group">
			<xsl:attribute name="name">
				<xsl:value-of select="fn:concat(fn:substring-after(./@rdf:about, '#'), 'Group')"/>
			</xsl:attribute>
			<!-- if there is rdfs:comment information, add it as an annotation element in the schema -->
			<xsl:call-template name="AddAnnotationInformation">
				<xsl:with-param name="ontologyComponent" select="."/>
			</xsl:call-template>
			<xsl:element name="xs:sequence">
				<!-- get the elements from the subClassOf structure of the current class -->
				<xsl:call-template name="PropertySubclasses">
					<xsl:with-param name="className" select="."/>
				</xsl:call-template>
			</xsl:element>
		</xsl:element>
		<!-- if the class has subclasses, also create a complex type with a choice compositor -->
		<xsl:variable name="classNameURI" select="./@rdf:about"/>
		<xsl:if test="fn:count(/rdf:RDF/owl:Class[rdfs:subClassOf/@rdf:resource = $classNameURI]) > 0">
			<xsl:call-template name="CreateChoiceOfSubclasses">
				<xsl:with-param name="className" select="$classNameURI"/>
				<xsl:with-param name="subclassNodeList" select="/rdf:RDF/owl:Class[rdfs:subClassOf/@rdf:resource = $classNameURI]"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<!-- this template generates a complex type in the XML schema document from the property axioms of the class passed to the template -->
	<xsl:template name="GenerateComplexType">
		<xsl:param name="classContext"/>
		<xsl:variable name="classNameString">
			<xsl:choose>
				<xsl:when test="fn:count(./rdfs:subClassOf/@rdf:resource) > 1">
					<!-- this class has 2 or more peer superclasses -->
					<xsl:value-of select="./rdfs:subClassOf[fn:position() = 1]/@rdf:resource"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="./rdfs:subClassOf/@rdf:resource"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!-- only generate the complex type if it has a superclass with property axioms that would be inherited 
			 via a model group structure or the class itself has property axioms to generate schema structure from -->
		<xsl:if test="./rdfs:subClassOf or /rdf:RDF/owl:Class[@rdf:about = $classNameString]/rdfs:subClassOf">
			<xsl:element name="xs:complexType">
				<xsl:attribute name="name">
					<xsl:value-of select="fn:concat(fn:substring-after(./@rdf:about, '#'), 'Type')"/>
				</xsl:attribute>
				<!-- if there is rdfs:comment information, add it as an annotation element in the schema -->
				<xsl:call-template name="AddAnnotationInformation">
					<xsl:with-param name="ontologyComponent" select="."/>
				</xsl:call-template>
				<xsl:element name="xs:sequence">
					<!-- find superclasses that have axioms in order to insert references to named model groups -->
					<xsl:variable name="nextParent" select="/rdf:RDF/owl:Class[@rdf:about = $classNameString]"/>
					<xsl:call-template name="ExamineParentClasses">
						<xsl:with-param name="parentClassNode" select="$nextParent"/>
					</xsl:call-template>
					<!-- get the elements from the subClassOf structure of the current class -->
					<xsl:call-template name="PropertySubclasses">
						<xsl:with-param name="className" select="."/>
					</xsl:call-template>
				</xsl:element>
			</xsl:element>
			<!-- also generate an element of that type if not already generated in the processing of object properties -->
			<xsl:variable name="className" select="./@rdf:about"/>
			<xsl:if test="fn:count(/rdf:RDF/owl:ObjectProperty/rdfs:range[@rdf:resource = $className]) = 0">
				<xsl:element name="xs:element">
					<xsl:attribute name="name">
						<xsl:value-of select="fn:substring-after(./@rdf:about, '#')"/>
					</xsl:attribute>
					<xsl:attribute name="type">
						<xsl:value-of select="fn:concat(fn:substring-after(./@rdf:about, '#'), 'Type')"/>
					</xsl:attribute>
				</xsl:element> 
			</xsl:if>
		</xsl:if>
	</xsl:template>
	
	<!-- this template recursively examines the superclasses of a given class to determine if the generated XML schema complex type needs a reference to 
		  a named model group holding the list of elements representing the property axioms of that superclass -->
	<xsl:template name="ExamineParentClasses">
		<xsl:param name="parentClassNode"/>
		<xsl:choose>
			<xsl:when test="not($parentClassNode)">
				<!-- no output -->
			</xsl:when>
			<xsl:otherwise>
				<!-- if this class has property axioms, then output an element referencing the named model group corresponding to the class structure -->
				<xsl:if test="$parentClassNode/rdfs:subClassOf/owl:Restriction">
					<xsl:variable name="nameString">
						<xsl:value-of select="$parentClassNode/@rdf:about"/>
					</xsl:variable>
					<xsl:element name="xs:group">
						<xsl:attribute name="ref">
							<xsl:value-of select="fn:substring-after($nameString, '#')"/>
							<xsl:text>Group</xsl:text>
						</xsl:attribute>
					</xsl:element>
				</xsl:if>
				<xsl:variable name="classNameString" select="$parentClassNode/rdfs:subClassOf/@rdf:resource"/>
				<xsl:variable name="nextParent" select="/rdf:RDF/owl:Class[@rdf:about = $classNameString]"/>
				<xsl:call-template name="ExamineParentClasses">
					<xsl:with-param name="parentClassNode" select="$nextParent"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- this template recursively examines the superclasses of a class to determine if there are any inherited properties from those superclasses -->
	<xsl:template name="CheckForSuperclassProperties">
		<xsl:param name="classNode"/>
		<!-- recursively look through the superclasses of this class to determine if any have property axioms -->
		<xsl:choose>
			<xsl:when test="$classNode/rdfs:subClassOf/owl:Restriction">
				<!-- class has one or more property axioms -->
				<xsl:value-of select="$classNode/@rdf:about"/>
			</xsl:when>
			<xsl:when test="$classNode/rdfs:subClassOf/@rdf:resource">
				<!-- class has a superclass -->
				<xsl:variable name="nextClassNode" select="/rdf:RDF/owl:Class[@rdf:about = $classNode/rdfs:subClassOf/@rdf:resource]"/>
				<xsl:call-template name="CheckForSuperclassProperties">
					<xsl:with-param name="classNode" select="$nextClassNode"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<!-- no superclass and no property axioms, so return the failure string -->
				<xsl:text>failure</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- this template generates a complex type with a choice compositor for classes that have subclasses -->
	<xsl:template name="CreateChoiceOfSubclasses">
		<xsl:param name="className"/>
		<xsl:param name="subclassNodeList"/>
		<xsl:element name="xs:complexType">
			<xsl:attribute name="name">
				<xsl:value-of select="fn:concat(fn:substring-after($className, '#'), 'Type')"/>
			</xsl:attribute>
			<!-- if there is rdfs:comment information, add it as an annotation element in the schema -->
			<xsl:call-template name="AddAnnotationInformation">
				<xsl:with-param name="ontologyComponent" select="."/>
			</xsl:call-template>
			<xsl:element name="xs:choice">
				<!--  Addition of min=0 on the 'xs:choice' element, to be able to create instances of a class that have subclasses 
				<xsl:attribute name="min">
					<xsl:text>0</xsl:text>
				</xsl:attribute> -->
				<xsl:for-each select="$subclassNodeList">
					<xsl:variable name="subclassName" select="./@rdf:about"/>
					<xsl:element name="xs:element">
						<xsl:attribute name="ref">
							<xsl:value-of select="fn:substring-after($subclassName, '#')"/>
						</xsl:attribute>
					</xsl:element>
				</xsl:for-each>
			</xsl:element>
		</xsl:element>
		<!-- if the class was not identified in a range restriction on an object property (resulting in an earlier element declatation) -->
		<!-- then also generate an element of the complex type -->
		<xsl:if test="fn:count(/rdf:RDF/owl:ObjectProperty/rdfs:range[@rdf:resource = $className]) = 0">
			<xsl:element name="xs:element">
				<xsl:attribute name="name">
					<xsl:value-of select="fn:substring-after($className, '#')"/>
				</xsl:attribute>
				<xsl:attribute name="type">
					<xsl:value-of select="fn:concat(fn:substring-after($className, '#'), 'Type')"/>
				</xsl:attribute>
			</xsl:element> 
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>
