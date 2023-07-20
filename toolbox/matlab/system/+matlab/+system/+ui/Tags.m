classdef Tags




    methods(Static)
        function dlgTag=getDialogTag(varargin)
            isMasking=slfeature('MLSysBlockNativeRenderDialog')>0;

            if nargin>0
                sysObjClassName=varargin{1};

                dlgTag=sysObjClassName;
                if(nargin>1)&&varargin{2}



                    if isMasking
                        sysObjClassName=strrep(sysObjClassName,'.','_');
                        dlgTag=['MATLABSystem.',sysObjClassName];
                    else
                        dlgTag='MATLABSystemBlock_SpecifySystemObject';
                    end
                end
            else

                if isMasking
                    dlgTag='MATLABSystem';
                else
                    dlgTag='MATLABSystemBlock_SpecifySystemObject';
                end
            end
        end

        function systemTag=getSystemTag()

            systemTag='System';
        end

        function dtypeTabTag=getDataTypeTabTag(tabNumber)



            if slfeature('MLSysBlockNativeRenderDialog')>0
                dtypeTabTag='DataTypesTab';
            else
                dtypeTabTag=[message('Simulink:dialog:DataTypesTab').getString,'Tab_',num2str(tabNumber)];
            end
        end

        function fiTag=getFiTabTag()

            if slfeature('MLSysBlockNativeRenderDialog')>0
                fiTag='SectionGroup2';
            else
                fiTag='fidialog';
            end
        end

        function tag=getHeaderTag(className)
            if slfeature('MLSysBlockNativeRenderDialog')>0
                tag='DescGroupVar';
            else
                tag=[className,'Header'];
            end
        end

        function tag=getHeaderTextTag(className)
            if slfeature('MLSysBlockNativeRenderDialog')>0
                tag='DescTextVar';
            else
                tag=[className,'HeaderText'];
            end
        end

        function tag=getHyperlinkTag(className)
            if slfeature('MLSysBlockNativeRenderDialog')>0
                tag='SourceCodeLink';
            else
                tag=[className,'HeaderHyperlink'];
            end
        end

        function label=getPropertyLabel(imd,propName)
            if slfeature('MLSysBlockNativeRenderDialog')>0
                tag=propName;
                a=find(imd,'Tag',tag);
                label=a.label;
            else
                tag=[propName,'Label'];
                a=find(imd,'Tag',tag);
                label=a.text;
            end
        end

        function tag=getTabContainerTag()
            if slfeature('MLSysBlockNativeRenderDialog')>0
                tag='TabsContainer';
            else
                tag='tabContainer';
            end
        end

        function tag=getDataTypesPanelTag()
            if slfeature('MLSysBlockNativeRenderDialog')>0
                tag='TypesTablePanel';
            else
                tag='dataTypeTablePanel';
            end
        end

        function tag=getDataTypeDescText()
            if slfeature('MLSysBlockNativeRenderDialog')>0
                tag='FixPtBlurbTextLabel';
            else
                tag='discText';
            end
        end
    end
end

