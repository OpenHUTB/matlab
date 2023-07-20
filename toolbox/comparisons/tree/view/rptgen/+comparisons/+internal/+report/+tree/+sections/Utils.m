classdef Utils<handle




    methods(Access=public,Static)

        function username=getUsername()
            if ispc
                username=getenv('USERNAME');
            else
                username=getenv('USER');
            end
        end

        function templateName=getTemplateName(section)
            if strcmp(section.Type,'PDF')

                templateName=section.TemplateName;
            else

                templateName='';
            end
        end

        function scaleImageToWidthInCM(image,width)
            oldWidth=str2double(regexp(image.Width,'[0-9]+','match','once'));
            oldHeight=str2double(regexp(image.Height,'[0-9]+','match','once'));
            ratio=oldHeight/oldWidth;

            maxHeight=21;
            if ratio*width<maxHeight
                image.Width=[num2str(width),'cm'];
                image.Height=[num2str(ratio*width),'cm'];
            else
                image.Height=[num2str(maxHeight),'cm'];
                image.Width=[num2str(maxHeight/ratio),'cm'];
            end
        end

        function evenlyDistributeTableColumnWidths(table,ncols)
            import mlreportgen.dom.TableColSpecGroup
            import mlreportgen.dom.TableColSpec
            import mlreportgen.dom.Width

            columnGroup=TableColSpecGroup();
            columnGroup.Span=ncols;

            columnSpec=TableColSpec;
            columnSpec.Span=ncols;
            widthStr=sprintf('%2.0f%s',100*1/ncols,'%');
            columnSpec.Style={Width(widthStr)};
            columnGroup.ColSpecs=columnSpec;
            table.ColSpecGroups=columnGroup;
        end

    end

end

