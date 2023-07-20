classdef(Abstract)LoopComponentConverter<mlreportgen.rpt2api.ComponentConverter




































    properties
        LoopVariableSuffix="";
    end

    methods(Access=protected)

        function init(obj,component,rptFileConverter)
            init@mlreportgen.rpt2api.ComponentConverter(obj,component,rptFileConverter);

            nestedLoopLvl=getNestedLoopLevel(obj);
            if nestedLoopLvl>0
                obj.LoopVariableSuffix=num2str(nestedLoopLvl);
            end

        end

        function lvl=getNestedLoopLevel(obj)








            lvl=0;
            compName=obj.Component.getName;
            parent=up(obj.Component);
            while~isempty(parent)
                if strcmp(parent.getName,compName)
                    lvl=lvl+1;
                end
                parent=up(parent);
            end
        end

        function writeSaveState(obj)




            fwrite(obj.FID,"% Save the current reporting state so that it"+newline);
            fwrite(obj.FID,"% can be restored upon exiting the loop."+newline);
            fwrite(obj.FID,"push(rptStateStack,copy(rptState));"+newline+newline);
        end

        function writeRestoreState(obj)



            fwrite(obj.FID,"% Restore the previous reporting state"+newline);
            fwrite(obj.FID,"rptState = pop(rptStateStack);"+newline+newline);
        end

        function name=getSectionVariableName(obj)
            name=obj.VariableName;
            if isempty(name)
                level=obj.RptFileConverter.CurrentSectionLevel;
                if level==1
                    name="rptChapterRptr";
                else
                    name=sprintf("rptSubsectLev%dRptr",level-1);
                end
            end
        end

        function writeObjectSectionCode(obj)
            if obj.Component.ObjectSection

                obj.RptFileConverter.CurrentSectionLevel=obj.RptFileConverter.CurrentSectionLevel+1;

                fwrite(obj.FID,"% Create a report section for this loop object."+newline);
                sectVariableName=getSectionVariableName(obj);

                if obj.RptFileConverter.CurrentSectionLevel==1
                    reporterName="Chapter";
                else
                    reporterName="Section";
                end

                fprintf(obj.FID,'%s = %s();\n',sectVariableName,reporterName);

                titleVarName="rptSectTitle";
                writeSectionTitleCode(obj,titleVarName,sectVariableName);

                fprintf(obj.FID,'%s.Title = %s;\n\n',...
                sectVariableName,titleVarName);

                if obj.Component.ObjectAnchor
                    idVarName="rptObjID";
                    writeObjectIdCode(obj,idVarName);
                    fprintf(obj.FID,'%s.LinkTarget = %s;\n\n',...
                    sectVariableName,idVarName);
                end

            end
        end

        function convertComponentChildren(obj)
            if obj.Component.ObjectSection
                parentContainer=top(obj.RptFileConverter.VariableNameStack);
                push(obj.RptFileConverter.VariableNameStack,getSectionVariableName(obj));
            end
            children=getComponentChildren(obj);
            n=numel(children);
            for i=1:n
                cmpn=children{i};
                c=getConverter(obj.RptFileConverter.ConverterFactory,...
                cmpn,obj.RptFileConverter);
                convert(c);
            end

            if obj.Component.ObjectSection
                pop(obj.RptFileConverter.VariableNameStack);
            end

            if obj.Component.ObjectSection
                fprintf(obj.FID,'append(%s,%s);\n\n',parentContainer,...
                getSectionVariableName(obj));
                obj.RptFileConverter.CurrentSectionLevel=obj.RptFileConverter.CurrentSectionLevel-1;
            end

            writeLoopEnd(obj);

            writeRestoreState(obj);

            writeEndBanner(obj);

        end

    end

    methods(Abstract,Access=protected)





        writeSectionTitleCode(obj,titleVarName,sectVariableName);





        writeObjectIdCode(obj,idVarName);



        writeLoopEnd(obj);
    end
end
