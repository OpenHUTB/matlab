classdef(Abstract)rptgen_sl_csl_c_blk_base<handle










    methods(Abstract,Access=protected)
        writeTypeAndName(obj)
    end

    methods(Access=protected)

        function writeObjectProperties(this,varName)

            if(this.Component.includeFcnProps)
                fprintf(this.FID,"%s.ObjectPropertiesReporter.ShowEmptyValues = %d;\n",varName,~this.Component.FcnPropsRemoveEmpty);
                fprintf(this.FID,"%s.ObjectPropertiesReporter.ShowPromptNames = %d;\n",varName,this.Component.FcnPropsShowNamePrompt);

                if(strcmpi(this.Component.FcnPropsPropListMode,'manual'))
                    numPropertyList=length(this.Component.FcnPropsPropList);
                    fprintf(this.FID,"rptCBlockObjectPropertyList = [");
                    for idx=1:numPropertyList
                        fprintf(this.FID,'"%s",',this.Component.FcnPropsPropList{idx});
                    end
                    fprintf(this.FID,"];\n");
                    fprintf(this.FID,"%s.ObjectPropertiesReporter.Properties = rptCBlockObjectPropertyList;\n",varName);
                end

                if(strcmpi(this.Component.FcnPropsTableTitleType,'manual'))
                    fprintf(this.FID,'%s.ObjectPropertiesReporter.PropertyTable.Title = "%s";\n',varName,this.Component.FcnPropsTableTitle);
                end

                if(~strcmpi(this.Component.FcnPropsHeaderType,'none'))
                    fprintf(this.FID,"%%Write C block object properties table headers\n");
                    this.writeTypeAndName();
                    fprintf(this.FID,"rptCBlockObjectPropertiesTableImpl = getImpl(%s, rptObj);\n",varName);
                    fprintf(this.FID,'rptCBlockObjectPropertiesArrayFun = arrayfun(@(n)isa(n,"mlreportgen.dom.FormalTable"),rptCBlockObjectPropertiesTableImpl.Children);\n');
                    fprintf(this.FID,'rptFormalTableIndex = find(rptCBlockObjectPropertiesArrayFun,1,"first");\n');

                    fprintf(this.FID,'if(~isempty(rptFormalTableIndex))\n');
                    fprintf(this.FID,"rptCBlockObjectPropertiesTableHeader1 = rptCBlockObjectPropertiesTableImpl.Children(rptFormalTableIndex).Header.entry(1,1);\n");
                    fprintf(this.FID,"rptCBlockObjectPropertiesTableHeader2 = rptCBlockObjectPropertiesTableImpl.Children(rptFormalTableIndex).Header.entry(1,2);\n");
                    if(strcmpi(this.Component.FcnPropsHeaderType,'manual'))
                        fprintf(this.FID,'rptCBlockObjectPropertiesTableHeader1.Children.Content = "%s";\n',this.Component.FcnPropsHeaderColumn1);
                        fprintf(this.FID,'rptCBlockObjectPropertiesTableHeader2.Children.Content = "%s";\n\n',this.Component.FcnPropsHeaderColumn2);
                    else

                        fprintf(this.FID,'rptCBlockObjectPropertiesTableHeader1.Children.Content = rptCBlockType;\n');
                        fprintf(this.FID,'rptCBlockObjectPropertiesTableHeader2.Children.Content = rptCBlockHeaderName;\n\n');
                    end
                    fprintf(this.FID,'end\n');
                end
            end
        end
    end
end
