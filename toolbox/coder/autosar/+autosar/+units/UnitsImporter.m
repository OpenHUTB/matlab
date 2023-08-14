




classdef UnitsImporter







    properties(Access=private)
ARDimNameToSLUnitExpression
SLUnitDatabase

M3iModel
    end

    methods
        function obj=UnitsImporter(m3iModel)
            obj.SLUnitDatabase=customUnitDatabase();
            obj.ARDimNameToSLUnitExpression=containers.Map;
            obj.M3iModel=m3iModel;
        end

        function importUnitsToDatabase(obj,filename)
            m3iUnits=autosar.mm.Model.findObjectByMetaClass(obj.M3iModel,Simulink.metamodel.types.Unit.MetaClass,true);
            m3iDims=autosar.mm.Model.findObjectByMetaClass(obj.M3iModel,Simulink.metamodel.types.Dimension.MetaClass,true);

            obj.importPhysicalQuantities(m3iDims);
            obj.importUnits(m3iUnits);

            obj.SLUnitDatabase.serializeToDisk(filename);
        end

        function importPhysicalQuantities(obj,dims)




            for ii=1:dims.size()
                dimension=dims.at(ii);


                [isBuiltIn,builtInDim]=obj.isPhysQuanBuiltIn(dimension.Name);
                if isBuiltIn


                    if~obj.isPhysQuanEquivelent(dimension,builtInDim)
                        autosar.mm.util.MessageReporter.createWarning(...
                        'autosarstandard:importer:PhysicalDimensionNotImported',dimension.Name);
                        continue;
                    end
                end

                if~obj.ARDimNameToSLUnitExpression.isKey(dimension.Name)

                    [unitEquation,physEquation]=obj.createSlUnitExpression(dimension);



                    obj.ARDimNameToSLUnitExpression(dimension.Name)=unitEquation;

                    if~isBuiltIn
                        obj.addPhysicalQuantity(...
                        dimension.Name,...
                        dimension.Name,...
                        dimension.Name,...
                        dimension.Name,...
                        physEquation)
                    end
                end
            end
        end

        function importUnits(obj,units)





            for ii=1:units.size
                unit=units.at(ii);


                if obj.isUnitBuiltIn(unit.Name)
                    autosar.mm.util.MessageReporter.createWarning(...
                    'autosarstandard:importer:UnitNotImported',unit.Name);
                    continue;
                end

                dim=unit.Dimension;

                unitExpression='';
                if~isempty(dim)
                    if obj.ARDimNameToSLUnitExpression.isKey(dim.Name)








                        unitExpression=obj.ARDimNameToSLUnitExpression(dim.Name);
                    else
                        if obj.isPhysQuanBuiltIn(dim.Name)
                            continue
                        end
                    end
                else
                    unitExpression='kg^0';
                end




                physQuantityName='';



                displayName=strrep(unit.Name,'_','\_');





                obj.addUnit(...
                unit.Name,...
                unit.Name,...
                unit.Name,...
                displayName,...
                1/(unit.ConvFactor),...
                -(unit.ConvOffset/unit.ConvFactor),...
                unitExpression,...
                physQuantityName);
            end
        end



        function addPhysicalQuantity(obj,...
            name,...
            symbol,...
            asciiSymbol,...
            displayName,...
            definitionExpression)



            newPhysicalQuantity=obj.SLUnitDatabase.createPhysicalQuantityToAdd();

            newPhysicalQuantity.name=name;
            newPhysicalQuantity.symbol=symbol;
            newPhysicalQuantity.asciiSymbol=asciiSymbol;
            newPhysicalQuantity.displayName=displayName;
            newPhysicalQuantity.definitionExpression=definitionExpression;

            obj.SLUnitDatabase.addPhysicalQuantity(newPhysicalQuantity);
        end

        function addUnit(obj,...
            name,...
            symbol,...
            asciiSymbol,...
            displayName,...
            conversionFactor,...
            conversionOffset,...
            definitionExpression,...
            physicalQuantity)



            newUnit=obj.SLUnitDatabase.createUnitToAdd();

            newUnit.name=name;
            newUnit.symbol=symbol;
            newUnit.asciiSymbol=asciiSymbol;
            newUnit.displayName=displayName;
            newUnit.conversionFactor=conversionFactor;
            newUnit.conversionOffset=conversionOffset;
            newUnit.definitionExpression=definitionExpression;
            newUnit.physicalQuantity=physicalQuantity;

            obj.SLUnitDatabase.addUnit(newUnit);
        end
    end

    methods(Static)
        function[slUnitExpression,slPhysQuanExpression]=createSlUnitExpression(m3iDimension)



























            slPhysQuanExpression='';
            slUnitExpression='';



            if isempty(m3iDimension.Symbol)

                slPhysQuanExpression='mass^0';
                slUnitExpression='kg^0';
                return
            end

            fundamentalDims=autosar.units.AutosarUnitMapping.ARFundamentalDims;

            for ii=1:length(fundamentalDims)
                baseUnit=fundamentalDims{ii};

                expIdx=strfind(m3iDimension.Symbol,baseUnit);
                if(~isempty(expIdx))
                    exponent=m3iDimension.BaseExponent.at(expIdx);
                    if exponent==0
                        continue;
                    end


                    if~isempty(slPhysQuanExpression)
                        slPhysQuanExpression=[slPhysQuanExpression,'*'];%#ok<AGROW>
                        slUnitExpression=[slUnitExpression,'*'];%#ok<AGROW>
                    end


                    unitSymbolSI=autosar.units.AutosarUnitMapping.ARFundementalDimsToSLSIUnits(baseUnit);
                    unitSymbolPhys=autosar.units.AutosarUnitMapping.ARDimsToSLPhysQuantity(baseUnit);


                    if exponent==1
                        slPhysQuanExpression=[slPhysQuanExpression,unitSymbolPhys];%#ok<AGROW>
                        slUnitExpression=[slUnitExpression,unitSymbolSI];%#ok<AGROW>
                    else
                        slPhysQuanExpression=[slPhysQuanExpression,'(',unitSymbolPhys,'^',num2str(exponent),')'];%#ok<AGROW>
                        slUnitExpression=[slUnitExpression,'(',unitSymbolSI,'^',num2str(exponent),')'];%#ok<AGROW>
                    end
                end
            end
        end

        function[isBuiltIn,slNativePhysQuan]=isPhysQuanBuiltIn(name)





            SLNativePhysQuantities=Simulink.UnitUtils.getFullList('','PhysicalQuantity');



            builtInIdx=...
            strcmp({SLNativePhysQuantities.Name},name)|...
            strcmp({SLNativePhysQuantities.Display},name);

            isBuiltIn=any(builtInIdx);
            if isBuiltIn

                slNativePhysQuan=SLNativePhysQuantities(builtInIdx);
            else
                slNativePhysQuan=SLNativePhysQuantities(1);
            end
        end

        function isBuiltIn=isUnitBuiltIn(name)



            isBuiltIn=false;

            SLNativeUnits=Simulink.UnitUtils.getFullList('','Units');



            for ii=1:length(SLNativeUnits)


                UnitPrefixes=SLNativeUnits(ii).UnitPrefixes;
                UnitPrefixes=strsplit(UnitPrefixes,',');
                UnitPrefixes{end+1}='';%#ok<AGROW> % Add no prefix case
                if~isempty(UnitPrefixes)


                    for jj=1:length(UnitPrefixes)
                        if startsWith(name,UnitPrefixes{jj})


                            noPrefixName=name(length(UnitPrefixes{jj})+1:end);
                            builtInIdx=any(...
                            [strcmp({SLNativeUnits(ii).Name},noPrefixName),...
                            strcmp({SLNativeUnits(ii).Display},noPrefixName),...
                            strcmp({SLNativeUnits(ii).Symbol},noPrefixName),...
                            strcmp({SLNativeUnits(ii).ASCIISymbol},noPrefixName)]);
                            if builtInIdx

                                isBuiltIn=true;
                                return;
                            end
                        end
                    end
                end
            end
        end

        function isEquivelent=isPhysQuanEquivelent(m3iDimension,slPhysQuan)




            isEquivelent=true;

            fundamentalDims=autosar.units.AutosarUnitMapping.ARFundamentalDims;

            for ii=1:length(fundamentalDims)
                baseUnit=fundamentalDims{ii};

                expIdx=strfind(m3iDimension.Symbol,baseUnit);
                if(~isempty(expIdx))
                    exponent=m3iDimension.BaseExponent.at(expIdx);
                    unitSymbolPhys=autosar.units.AutosarUnitMapping.ARDimsToSLPhysQuantity(baseUnit);

                    switch exponent
                    case 0



                        if~isempty(strfind(slPhysQuan.Definition,unitSymbolPhys))
                            isEquivelent=false;
                            return;
                        end
                    case 1



                        if~isempty(strfind(slPhysQuan.Definition,[unitSymbolPhys,'^']))
                            isEquivelent=false;
                            return;
                        end
                    otherwise








                        regexStr=[unitSymbolPhys,'\^([0-9-]+)'];
                        exponentStr=regexp(slPhysQuan.Definition,regexStr,'tokens');


                        if isempty(exponentStr)
                            isEquivelent=false;
                            return;
                        end


                        if exponent~=str2double(exponentStr)
                            isEquivelent=false;
                            return;
                        end

                    end
                end
            end
        end

    end
end




