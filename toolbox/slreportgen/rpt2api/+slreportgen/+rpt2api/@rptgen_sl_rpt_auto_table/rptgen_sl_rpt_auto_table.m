classdef(Abstract)rptgen_sl_rpt_auto_table<handle










    properties(Abstract,Access=protected)



        autoTableObjectType;

        autoTableHeaderName;

        autoTableObjectTarget;
    end

    methods(Access=protected)

        function writeAutoTableProperties(this,varName)

            fprintf(this.FID,"%s.ShowEmptyValues = %d;\n\n",varName,~this.Component.RemoveEmpty);

            if(strcmpi(this.Component.TitleType,'manual'))
                fprintf(this.FID,'%s.PropertyTable.Title = "%s";\n\n',varName,this.Component.Title);
            elseif(strcmpi(this.Component.TitleType,'name'))
                fprintf(this.FID,'rptAutoTableTitle = %s + " - " + %s;\n',this.autoTableObjectType,this.autoTableHeaderName);
                fprintf(this.FID,'%s.PropertyTable.Title = rptAutoTableTitle;\n\n',varName);
            end

            if(~strcmpi(this.Component.HeaderType,'none'))
                fprintf(this.FID,"rptAutoTableImpl = getImpl(%s, rptObj);\n",varName);
                fprintf(this.FID,"if(~isempty(rptAutoTableImpl))\n");
                fprintf(this.FID,"rptAutoTableArrayFun = arrayfun(@(n)isa(n, 'mlreportgen.dom.FormalTable'), rptAutoTableImpl.Children);\n");
                fprintf(this.FID,"rptFormalTableIndex = find(rptAutoTableArrayFun, 1, 'first');\n");

                fprintf(this.FID,"rptAutoTableHeader1 = rptAutoTableImpl.Children(rptFormalTableIndex).Header.entry(1,1);\n");
                fprintf(this.FID,"rptAutoTableHeader2 = rptAutoTableImpl.Children(rptFormalTableIndex).Header.entry(1,2);\n");

                if(strcmpi(this.Component.HeaderType,'manual'))
                    fprintf(this.FID,'rptAutoTableHeader1.Children.Content = "%s";\n',this.Component.HeaderColumn1);
                    fprintf(this.FID,'rptAutoTableHeader2.Children.Content = "%s";\n\n',this.Component.HeaderColumn2);
                else

                    fprintf(this.FID,'rptAutoTableHeader1.Children.Content = %s;\n',this.autoTableObjectType);
                    fprintf(this.FID,'rptAutoTableHeader2.Children.Content = %s;\n\n',this.autoTableHeaderName);
                end
                fprintf(this.FID,"end\n");
            end

        end
    end
end
