classdef SelectionStatus


    enumeration
None
Single
MultiSiblings
MultiNonSiblings
Heterogeneous
    end

    methods(Static)
        function[selections,selectionStatus]=getCurrentSelectionAndType(data)

            selections=[];
            className='';
            isMultiSelection=false;
            uniqueTypeSelection=true;
            if isempty(data)
                selectionStatus=slreq.gui.SelectionStatus.None;
                return;
            end
            for n=1:length(data)
                if isa(data,'DAStudio.DAObjectProxy')

                    d=data(n);
                    dasObj=d.getMCOSObjectReference();
                else

                    dasObj=data{n};
                end
                if n==1
                    selections=dasObj;
                    className=class(dasObj);
                else
                    isMultiSelection=true;
                    if isa(dasObj,className)
                        selections(n)=dasObj;%#ok<AGROW>
                    else
                        uniqueTypeSelection=false;
                        break;
                    end
                end
            end


            if isMultiSelection
                if uniqueTypeSelection
                    if selections.isSiblings
                        selectionStatus=slreq.gui.SelectionStatus.MultiSiblings;
                    else
                        selectionStatus=slreq.gui.SelectionStatus.MultiNonSiblings;
                    end
                else


                    selections=[];
                    selectionStatus=slreq.gui.SelectionStatus.Heterogeneous;
                end
            elseif isempty(selections)
                selectionStatus=slreq.gui.SelectionStatus.None;
            else
                selectionStatus=slreq.gui.SelectionStatus.Single;
            end
        end

        function tf=enableOuterPanel(view)
            if isa(view,'slreq.gui.RequirementsEditor')||isa(view,'slreq.internal.gui.SfReqView')


                tf=true;
            else


                selectionStatus=view.getSelectionStatus();
                isMultiSelection=selectionStatus==slreq.gui.SelectionStatus.MultiNonSiblings...
                ||selectionStatus==slreq.gui.SelectionStatus.MultiSiblings...
                ||selectionStatus==slreq.gui.SelectionStatus.Heterogeneous;
                tf=~isMultiSelection;
            end
        end

        function tf=isDragNDropLinkingAllowed(view)
            tf=false;
            selectionStatus=view.getSelectionStatus();
            selections=view.getCurrentSelection;
            if isa(selections,'slreq.das.Requirement')
                tf=selectionStatus==slreq.gui.SelectionStatus.Single...
                ||selectionStatus==slreq.gui.SelectionStatus.MultiNonSiblings...
                ||selectionStatus==slreq.gui.SelectionStatus.MultiSiblings;
            end
        end
    end
end

