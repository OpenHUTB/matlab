

classdef LegacyProjectBuildUtilities


    methods(Static)


        function options=addAdditionalFiles(options,prjStruct)
            additionalFiles=prjStruct.fileset_resources;



            if isstruct(additionalFiles)
                options.AdditionalFiles=additionalFiles.file;
            end
        end


        function options=addCommonBuildOptions(options,prjStruct)
            options.OutputDir=prjStruct.param_intermediate;
            options.AutoDetectDataFiles=true;
            options.Verbose=true;
        end


        function options=addSampleFiles(options,prjStruct)
            sampleFiles=prjStruct.fileset_examples;



            if isstruct(sampleFiles)
                options.SampleGenerationFiles=sampleFiles.file;
            end
        end



        function options=addSupportPackages(options,prjStruct)

            if isstruct(prjStruct.param_support_packages)

                enabledSupportPackages="";
                index=1;
                supportPackageXML=prjStruct.param_support_packages.item;

                for i=1:length(supportPackageXML)


                    name=tempname;
                    fileID=fopen(name,'w');
                    o1=onCleanup(@()fclose(fileID));
                    fprintf(fileID,'%s',supportPackageXML(i));


                    o2=onCleanup(@()delete(name));


                    supportPackageStruct=readstruct(name,'FileType','xml');


                    if strcmp(supportPackageStruct.enabledAttribute,"true")
                        enabledSupportPackages(index)=supportPackageStruct.nameAttribute;
                        index=index+1;
                    end
                end
                options.SupportPackages=enabledSupportPackages;

            else
                options.SupportPackages='none';
            end

        end


        function classmap=generateClassmapFromPRJ(prjStruct)
            try
                classStruct=prjStruct.fileset_classes.entity_package.entity_class;
                classmap=containers.Map;

                for i=1:length(classStruct)
                    classmap(classStruct(i).nameAttribute)=classStruct(i).file;
                end
            catch

                error(message('Compiler:build:compatibility:invalidClassDefinition'))
            end
        end



        function compName=getNamespacedComponentName(prjStruct)
            if strcmp(prjStruct.param_namespace,"")
                compName=prjStruct.param_appname;
            elseif strcmp(prjStruct.param_target_type,"subtarget.java.package")||...
                strcmp(prjStruct.param_target_type,"subtarget.net.component")


                compName=prjStruct.param_namespace;
            else
                compName=prjStruct.param_namespace+"."+prjStruct.param_appname;
            end
        end


        function options=configureDataMarshallingRules(options,prjStruct)

            if isstruct(prjStruct.param_function_data)

                dmStruct=prjStruct.param_function_data;





                rules=split(dmStruct.item','-');
                notI=1;
                numFiles=1;
                reformattedRules={};




                if length(dmStruct.item)==1
                    rules=rules';
                end

                while notI<=length(rules(:,1))
                    thisName=rules(notI,1);
                    theseRules=rules(notI,2);
                    notI=notI+1;
                    while notI<=size(rules,1)&&strcmp(thisName,rules(notI,1))
                        theseRules(end+1)=rules(notI,2);
                        notI=notI+1;
                    end
                    reformattedRules{numFiles,1}=thisName;
                    reformattedRules{numFiles,2}=theseRules;
                    numFiles=numFiles+1;
                end



                throwWarning=false;
                if size(reformattedRules,1)~=prjStruct.fileset_exports.file.length
                    throwWarning=true;
                else
                    if size(reformattedRules,1)>1
                        for notI=2:size(reformattedRules,1)
                            if~all(strcmp(reformattedRules{1,2},reformattedRules{notI,2}))
                                throwWarning=true;
                            end
                        end
                    end
                end
                if throwWarning
                    warning(message('Compiler:build:compatibility:dataMarshallingWarning'))
                else


                    options.ReplaceExcelBlankWithNaN=any(strcmpi(reformattedRules{1,2},"replaceBlankWithNaN"));
                    options.ConvertExcelDateToString=any(strcmpi(reformattedRules{1,2},"convertDateToString"));
                    options.ReplaceNaNToZeroInExcel=any(strcmpi(reformattedRules{1,2},"replaceNaNWithZero"));
                    options.ConvertNumericOutToDateInExcel=any(strcmpi(reformattedRules{1,2},"convertNumericToDate"));
                end
            end
        end

    end
end

