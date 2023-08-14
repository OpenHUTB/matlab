classdef(Abstract)BaseResponseView<handle





    properties(Constant)
        ORDER_SPINNER_WIDTH=75;
        UIEDITFIELD_WIDTH=100;
        CONSTRAINTS_DROPDOWN_WIDTH=365;
        UIEDITFIELD_PRECISION='%11.10g';
    end

    properties(Access=protected,Transient)
ParentAccordion
    end

    events

responseViewChange
    end

    methods(Abstract)



        updateGroups(this,viewSettings);

        isGroupsRendered(this);


        flag=isReadyForScript(this);
    end

    methods


        function accordionPanel=addSpecificationsGroup(this)

            import signal.task.internal.BaseTask
            import signal.task.internal.designfilt.msgid2txt



            accordionPanel=BaseTask.createAccordionPanel(...
            this.ParentAccordion,...
            msgid2txt('SpecificationsHeader'),...
            'Specifications');
        end

        function accordionPanel=addAlgorithmGroup(this)

            import signal.task.internal.BaseTask
            import signal.task.internal.designfilt.msgid2txt



            accordionPanel=BaseTask.createAccordionPanel(this.ParentAccordion,...
            msgid2txt('AlgorithmHeader'),'Algorithm');
            accordionPanel.Collapsed=true;
        end

        function[designOptionsMainAccordion,designOptionsPanel]=addDesignOptionsGroup(~,algorithsmGrid)

            import signal.task.internal.BaseTask
            import signal.task.internal.designfilt.msgid2txt

            designOptionsMainAccordion=BaseTask.createAccordion(algorithsmGrid,'DesignOptions');

            designOptionsPanel=BaseTask.createAccordionPanel(...
            designOptionsMainAccordion,msgid2txt('DesignOptionsHeader'),...
            'DesignOptions');
            designOptionsPanel.Collapsed=true;
        end
    end

    methods(Static,Hidden)
        function setLayout(widget,row,col)

            widget.Layout.Row=row;
            widget.Layout.Column=col;
        end

        function flag=isPositiveFiniteNumber(x)

            flag=~isempty(x)&&isscalar(x)&&isnumeric(x)&&isreal(x)&&...
            isfinite(x)&&(x>0);
        end
    end
end
