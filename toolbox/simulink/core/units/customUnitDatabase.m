




classdef customUnitDatabase<handle

    properties
unitDatabase
    end

    properties(Access=private)
model
    end
    methods(Access=private)

        function temp=createRationalConversion(~,num,den)
            temp=struct('numerator',int32(num),'denominator',...
            int32(den));
        end
    end

    methods(Access=public)
        function obj=customUnitDatabase(filePath)
            obj.model=mf.zero.Model();
            if nargin>0


                parser=mf.zero.io.XmlParser;
                parser.Model=obj.model;
                extractedFileName='UserDefinedUnitDBInMemory';
                Simulink.UnitDatabaseMldatx.unpackXMLStreamFromMldatx(filePath,extractedFileName);
                result=parser.parseFile(extractedFileName);
                delete 'UserDefinedUnitDBInMemory';



                for idx=1:length(result)
                    if isa(result(idx),'sl.UnitRepository.UnitDatabase')
                        obj.unitDatabase=result(idx);
                    end
                end

            else

                obj.unitDatabase=sl.UnitRepository.UnitDatabase(obj.model);

            end
        end
        function customDB=addUnit(customDB,aUserUnit)
            aUnit=sl.UnitRepository.Unit(customDB.model);

            aUnit.mName=aUserUnit.name;
            aUnit.mSymbol=aUserUnit.symbol;
            aUnit.mDispName=aUserUnit.displayName;
            aUnit.mExpr=aUserUnit.definitionExpression;
            aUnit.mAsciiSymbol=aUserUnit.asciiSymbol;
            aUnit.mPhysicalQuantity=aUserUnit.physicalQuantity;
            aUnit.mUserInformation=aUserUnit.userInformation;

            for idx=1:length(aUserUnit.provenance)
                title=aUserUnit.provenance{idx};
                aUnit.unitProvenance.add(customDB.findProvenance(title));
            end

            if isa(aUserUnit.conversionFactor,'double')

                if(aUserUnit.conversionOffset==0.0)
                    aUnit.mConversionFactor=num2str(aUserUnit.conversionFactor);
                    aUnit.mConversionType=int32(ConversionFactorEnum.DOUBLE);
                else
                    aUnit.mConversionFactor=[num2str(aUserUnit.conversionFactor)...
                    ,',',num2str(aUserUnit.conversionOffset)];
                    aUnit.mConversionType=int32(ConversionFactorEnum.DOUBLE_AFFINE);
                end
            else

                if(aUserUnit.conversionOffset.numerator==0)
                    aUnit.mConversionFactor=...
                    [num2str(aUserUnit.conversionFactor.numerator),...
                    ',',num2str(aUserUnit.conversionFactor.denominator)];
                    aUnit.mConversionType=int32(ConversionFactorEnum.RATIONAL);
                else
                    aUnit.mConversionFactor=...
                    [num2str(aUserUnit.conversionFactor.numerator),...
                    ',',num2str(aUserUnit.conversionFactor.denominator),...
                    ',',num2str(aUserUnit.conversionOffset.numerator),...
                    ',',num2str(aUserUnit.conversionOffset.denominator)];
                    aUnit.mConversionType=int32(ConversionFactorEnum.RATIONAL_AFFINE);
                end

            end
            customDB.unitDatabase.unit.add(aUnit);
        end

        function customDB=addPhysicalQuantity(customDB,aUserPhysicalQuantity)

            aPhysicalQuantity=sl.UnitRepository.PhysicalQuantity(customDB.model);

            aPhysicalQuantity.mName=aUserPhysicalQuantity.name;
            aPhysicalQuantity.mSymbol=aUserPhysicalQuantity.symbol;
            aPhysicalQuantity.mDispName=aUserPhysicalQuantity.displayName;
            aPhysicalQuantity.mExpr=aUserPhysicalQuantity.definitionExpression;
            aPhysicalQuantity.mAsciiSymbol=aUserPhysicalQuantity.asciiSymbol;
            aPhysicalQuantity.mUserInformation=aUserPhysicalQuantity.userInformation;

            for idx=1:length(aUserPhysicalQuantity.provenance)
                title=aUserPhysicalQuantity.provenance{idx};
                aPhysicalQuantity.unitprovenance.add(customDB.findProvenance(title));
            end

            customDB.unitDatabase.physicalquantity.add(aPhysicalQuantity);
        end

        function customDB=addProvenance(customDB,aUserProvenance)
            aProvenance=sl.UnitRepository.UnitProvenance(customDB.model);
            aProvenance.mName=aUserProvenance.identifier;
            aProvenance.mTitle=aUserProvenance.title;
            aProvenance.mSubtitle=aUserProvenance.subTitle;
            aProvenance.mOrganization=aUserProvenance.organization;
            aProvenance.mFullName=aUserProvenance.fullName;
            aProvenance.mEdition=aUserProvenance.edition;
            aProvenance.mYear=aUserProvenance.year;

            for idx=1:length(aUserProvenance.urlList)
                aProvenance.mURLs.add(aUserProvenance.urlList{idx});
            end

            customDB.unitDatabase.unitProvenance.add(aProvenance);
        end

        function aProvenance=createProvenanceToAdd(~)
            aProvenance=...
            struct('identifier','','title','User Defined','subTitle','',...
            'organization','User','fullName','',...
            'urlList',cell(1,1),'edition','',...
            'year',2016);
        end

        function aUserUnit=createUnitToAdd(customDB,rationalConversionTemplate)
            aFactor=1.0;
            aOffset=0.0;



            if(nargin>1)&&rationalConversionTemplate
                aFactor=customDB.createRationalConversion(1,1);
                aOffset=customDB.createRationalConversion(0,1);
            end

            aUserUnit=struct('name','','symbol','','displayName','',...
            'definitionExpression','','asciiSymbol','',...
            'conversionFactor',aFactor,...
            'conversionOffset',aOffset,...
            'physicalQuantity','','provenance',cell(1,1),...
            'userInformation','');
        end

        function aUserPhysicalQuantity=createPhysicalQuantityToAdd(~)
            aUserPhysicalQuantity=struct('name','','symbol','','displayName','',...
            'definitionExpression','','asciiSymbol','','provenance',cell(1,1),'userInformation','');
        end

        function serializeToDisk(customDB,filePath)
            serializer=mf.zero.io.XmlSerializer;
            currentPath=pwd;
            [start,~]=regexp(filePath,currentPath);
            Dir=fileparts(filePath);


            if(isdir(Dir))
                actualPath=filePath;
            else
                if(isempty(start))
                    actualPath=fullfile(currentPath,filePath);
                else
                    actualPath=filePath;
                end
            end

            actualPath=append(actualPath,'.slunitdb.mldatx');
            content=serializer.serializeToString(customDB.model);
            Simulink.UnitDatabaseMldatx.packageXMLStreamToMldatx(content,actualPath);

        end

        function listing=getFullUnitsList(customDB)
            listing=struct('units',[],'physicalQuantities',[],'provenances',[]);



            unitList=customDB.unitDatabase.unit.toArray();
            userUnitList=cell(1,length(unitList));
            for idx=1:length(unitList)
                aUserUnit=customDB.createUnitToAdd();
                aUnit=unitList(idx);

                aUserUnit.name=aUnit.mName;
                aUserUnit.symbol=aUnit.mSymbol;
                aUserUnit.displayName=aUnit.mDispName;
                aUserUnit.definitionExpression=aUnit.mExpr;
                aUserUnit.asciiSymbol=aUnit.mAsciiSymbol;


                listOfFactors=strsplit(aUnit.mConversionFactor,',');

                if(aUnit.mConversionType==ConversionFactorEnum.DOUBLE||...
                    aUnit.mConversionType==ConversionFactorEnum.DOUBLE_AFFINE)
                    aUserUnit.conversionFactor=str2double(listOfFactors{1});
                    if(aUnit.mConversionType==ConversionFactorEnum.DOUBLE_AFFINE)
                        aUserUnit.conversionOffset=str2double(listOfFactors{2});
                    else
                        aUserUnit.conversionOffset=0.0;
                    end
                else
                    assert(aUnit.mConversionType==ConversionFactorEnum.RATIONAL||...
                    aUnit.mConversionType==ConversionFactorEnum.RATIONAL_AFFINE);

                    aUserUnit.conversionFactor=...
                    customDB.createRationalConversion(...
                    str2double(listOfFactors{1}),str2double(listOfFactors{2}));


                    if(aUnit.mConversionType==ConversionFactorEnum.RATIONAL_AFFINE)
                        aUserUnit.conversionOffset=...
                        customDB.createRationalConversion(...
                        str2double(listOfFactors{3}),...
                        str2double(listOfFactors{4}));
                    else
                        aUserUnit.conversionOffset=...
                        customDB.createRationalConversion(0,1);

                        aUserUnit.conversionOffset=0.0;
                    end

                end
                aUserUnit.physicalQuantity=aUnit.mPhysicalQuantity;
                aUserUnit.userInformation=aUnit.mUserInformation;

                provenanceList=aUnit.unitProvenance.toArray;
                title=cell(1,length(provenanceList));
                for idxList=1:length(provenanceList)
                    title{idxList}=provenanceList(idxList).mName;
                end
                aUserUnit.provenance=title;

                userUnitList{idx}=aUserUnit;
            end


            physicalQuantityList=customDB.unitDatabase.physicalquantity.toArray();
            userPhysicalQuantityList=cell(1,length(physicalQuantityList));

            for idx=1:length(physicalQuantityList)
                aUserPhysicalQuantity=customDB.createPhysicalQuantityToAdd();
                aPhysicalQuantity=physicalQuantityList(idx);

                aUserPhysicalQuantity.name=aPhysicalQuantity.mName;
                aUserPhysicalQuantity.symbol=aPhysicalQuantity.mSymbol;
                aUserPhysicalQuantity.displayName=aPhysicalQuantity.mDispName;
                aUserPhysicalQuantity.definitionExpression=aPhysicalQuantity.mExpr;
                aUserPhysicalQuantity.asciiSymbol=aPhysicalQuantity.mAsciiSymbol;

                provenanceList=aPhysicalQuantity.unitprovenance.toArray;
                title=cell(1,length(provenanceList));
                for idxList=1:length(provenanceList)
                    title{idxList}=provenanceList(idxList).mName;
                end
                aUserPhysicalQuantity.provenance=title;

                aUserPhysicalQuantity.userInformation=aUnit.mUserInformation;
                userPhysicalQuantityList{idx}=aUserPhysicalQuantity;
            end


            provenanceList=customDB.unitDatabase.unitProvenance.toArray();
            userProvenanceList=cell(1,length(provenanceList));
            for idx=1:length(provenanceList)
                aUserProvenance=customDB.createProvenanceToAdd();
                aProvenance=provenanceList(idx);

                aUserProvenance.identifier=aProvenance.mName;
                aUserProvenance.title=aProvenance.mTitle;
                aUserProvenance.subTitle=aProvenance.mSubtitle;
                aUserProvenance.organization=aProvenance.mOrganization;
                aUserProvenance.fullName=aProvenance.mFullName;
                aUserProvenance.edition=aProvenance.mEdition;
                aUserProvenance.year=double(aProvenance.mYear);

                aURLList=aProvenance.mURLs.toArray();
                aUserProvenance.urlList=cell(1,length(aURLList));
                for urlListIdx=1:length(aURLList)
                    aUserProvenance.urlList(urlListIdx)=aURLList(urlListIdx);
                end

                userProvenanceList{idx}=aUserProvenance;
            end


            listing.units=userUnitList;
            listing.physicalQuantities=userPhysicalQuantityList;
            listing.provenances=userProvenanceList;
        end

    end

    methods(Access=private)
        function provenanceObject=findProvenance(customDB,aProvenanceTitle)
            provenanceList=customDB.unitDatabase.unitProvenance.toArray();
            provenanceObject=provenanceList(strcmp({provenanceList.mName},aProvenanceTitle));
        end
    end

end
