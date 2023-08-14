




classdef StyleGroup<handle
    properties
        styler=[];
        style=[];
        selector=[];
        rule=[];
        isBdSelect=false;
        handleList=[];
        selectorName='';
        bdHandles=[];
    end

    methods
        function this=StyleGroup(styler,style,selectorName,handleList,options)
            if(nargin<5)||isempty(options)
                options.selectDescendants=false;
            end

            this.styler=styler;
            this.style=style;
            this.selectorName=selectorName;
            this.handleList=handleList;
            if strncmp(this.selectorName,'BD_',3)


                this.isBdSelect=true;
                classSelectorBDGrey=diagram.style.ClassSelector(this.selectorName);
                if options.selectDescendants
                    greyAllSimulinkSelector=diagram.style.DescendantSelector({this.selectorName},{},{},{'simulink'});
                    this.selector={greyAllSimulinkSelector,classSelectorBDGrey};
                else
                    this.selector={classSelectorBDGrey};
                end
                this.setItems(handleList);
            else

                this.selector=diagram.style.ClassSelector(this.selectorName);
                this.setItems(handleList);
            end
            this.show();
        end

        function show(this)
            if isempty(this.rule)
                if this.isBdSelect
                    bdCnt=length(this.selector);
                    for idx=1:bdCnt
                        sel=this.selector{1,idx};
                        stylerrule=this.styler.addRule(this.style,sel);
                        this.rule=[this.rule,stylerrule];
                    end
                else
                    this.rule=this.styler.addRule(this.style,this.selector);
                end
            end
        end

        function hide(this)
            if this.isBdSelect
                bdCnt=length(this.selector);
                for idx=1:bdCnt
                    if~isempty(this.rule)
                        this.rule(1).remove();
                        this.rule(1)=[];
                    end
                end
            else
                if~isempty(this.rule)
                    this.rule.remove();
                    this.rule=[];
                end
            end
        end

        function updateStyle(this,style)
            visible=~isempty(this.rule);

            if visible
                this.hide();
            end

            this.style=style;

            if visible
                this.show();
            end
        end

        function setItems(this,handles)

            if~isempty(this.handleList)
                handlesCellArray=num2cell(this.handleList(:)');
                this.removeStyle(handlesCellArray);
            end


            if~isempty(handles)
                handlesCellArray=num2cell(handles(:)');
                this.applyStyle(handlesCellArray);
            end
            this.handleList=handles;
        end

        function addItems(this,handles)

            newHandles=setdiff(handles,this.handleList);


            if~isempty(newHandles)
                handlesCellArray=num2cell(newHandles(:)');
                this.applyStyle(handlesCellArray);
                this.handleList=union(this.handleList,newHandles);
            end
        end

        function removeItem(this,handle)
            if ismember(handle,this.handleList)
                this.removeStyle(handle);
                this.handleList(this.handleList==handle)=[];
            end
        end

        function clear(this)

            if this.isBdSelect
                for i=1:length(this.rule)
                    this.rule(i).remove();
                end
                this.rule=[];
            else
                this.hide();
            end

            if~isempty(this.handleList)
                handlesCellArray=reshape(num2cell(this.handleList),1,numel(this.handleList));
                this.removeStyle(handlesCellArray);
            end
        end

        function applyStyle(this,handles)

            if this.isBdSelect
                if~iscell(handles)
                    handles={handles};
                end

                for i=1:length(handles)
                    handles{i}=diagram.resolver.resolve(handles{i},'diagram');
                end
            end

            this.styler.applyClass(handles,this.selectorName);
        end

        function removeStyle(this,handles)

            if this.isBdSelect
                if~iscell(handles)
                    handles={handles};
                end

                for i=1:length(handles)
                    handles{i}=diagram.resolver.resolve(handles{i},'diagram');
                end
            end

            this.styler.removeClass(handles,this.selectorName);
        end
    end
end
