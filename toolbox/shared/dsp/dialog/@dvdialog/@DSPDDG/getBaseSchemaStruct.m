function dlgStruct=getBaseSchemaStruct(this,parameters,maskDescription,optPane)

















    if nargin<3
        maskDescription=this.Block.MaskDescription;
    end

    description.Type='text';
    description.Name=udtGetMessageString(maskDescription);
    description.Tag='description';
    description.WordWrap=1;

    descriptionPane=udtGetContainerWidgetBase('group',this.Block.MaskType,...
    'descriptionPane');
    descriptionPane.Items={description};
    descriptionPane.RowSpan=[1,1];
    descriptionPane.ColSpan=[1,1];

    mainPane=udtGetContainerWidgetBase('panel','','mainPane');
    if nargin<4
        if iscell(parameters)
            nitems=length(parameters{1}.Items);
            parameters{1}.LayoutGrid=[nitems+1,1];
            parameters{1}.RowStretch=[zeros(1,nitems),1];
            mainPane.Items=cat(2,{descriptionPane},parameters);
        else
            mainPane.Items={descriptionPane,parameters};
        end
        mainPane.Tag='mainPane';

        numItems=1+length(mainPane.Items);
        mainPane.LayoutGrid=[numItems,1];
        mainPane.RowStretch=[zeros(1,numItems-1),1];
        mainPane.RowSpan=[1,1];
        mainPane.ColSpan=[1,1];
    else
        if iscell(parameters)
            nitems=length(parameters{1}.Items);
            parameters{1}.LayoutGrid=[nitems+1,1];
            parameters{1}.RowStretch=[zeros(1,nitems),1];
            mainPane.Items=cat(2,{descriptionPane},{optPane},parameters);
        else
            mainPane.Items={descriptionPane,optPane,parameters};
        end
        mainPane.Tag='mainPane';
        mainPane.LayoutGrid=[4,1];
        mainPane.RowStretch=[0,0,0,1];
        mainPane.RowSpan=[1,1];
        mainPane.ColSpan=[1,1];
    end




    title=this.Block.Name;

    title(double(title)==10)=' ';
    dlgStruct.DialogTitle=['Block Parameters: ',title];
    dlgStruct.HelpMethod='slhelp';
    dlgStruct.HelpArgs={this,this.Block.Handle};
    dlgStruct.Items={mainPane};
    dlgStruct.DialogTag=this.Block.MaskType;
    dlgStruct.PreApplyCallback='udtDDGPreApply';
    dlgStruct.PreApplyArgs={this,'%dialog'};
    dlgStruct.PostApplyCallback='udtPostApply';
    dlgStruct.PostApplyArgs={this,'%dialog'};
    dlgStruct.SmartApply=0;
    dlgStruct.CloseMethod='closeCallback';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};






    [isLibrary,isLocked]=this.isLibraryBlock(this.Block);
    if isLibrary&&isLocked
        dlgStruct.DisableDialog=1;

        return;
    end


    if any(strcmp(this.Root.SimulationStatus,{'running','paused'}))
        dlgStruct=this.disableNontunables(dlgStruct);
    end


    function parameters=addWidgetToMainParameters(parameters,widgetToAdd,position)%#ok






















        if iscell(parameters)





            error(message('dspshared:getBaseSchemaStruct:invalidFcnInput1'));
        else





            if isfield(parameters,'Tabs')
                leafNode='parameters.Tabs{1}.Items';
                previousNode='parameters.Tabs{1}';

            else
                leafNode='parameters.Items';
                previousNode='parameters';

            end




            while isfield(eval([leafNode,'{1}']),'Items')
                previousNode=leafNode;
                leafNode=[leafNode,'{1}.Items'];%#ok<AGROW>
            end


            originalNumItems=length(eval(leafNode));
            posNum=str2double(position);
            if~strcmpi(position,'end')&&((posNum<1)||(posNum>originalNumItems))
                error(message('dspshared:getBaseSchemaStruct:invalidFcnInput2'));
            end

            if strcmpi(position,'end')

                eval([leafNode,'{end+1} = widgetToAdd;']);
            else




                for idx=originalNumItems:-1:posNum

                    eval([leafNode,'{',num2str(idx),'}.RowSpan = [',num2str([idx+1,idx+1]),'];']);

                    eval([leafNode,'{',num2str(idx+1),'} = ',leafNode,'{',num2str(idx),'};']);
                end
                eval([leafNode,'{',position,'} = widgetToAdd;']);
            end




            if strcmpi(previousNode,'parameters')


                eval([previousNode,'.LayoutGrid = [originalNumItems+2 1];']);
                eval([previousNode,'.RowStretch = [zeros(1, originalNumItems+1), 1];']);
            else

                eval([previousNode,'{1}.LayoutGrid = [originalNumItems+2 1];']);
                eval([previousNode,'{1}.RowStretch = [zeros(1, originalNumItems+1), 1];']);
            end
        end


        function str=udtGetMessageString(strOrID)
















            if regexp(strOrID,'[a-zA-Z]\w*(?:[:][a-zA-Z]\w*){2,}')==1

                str=DAStudio.message(strOrID);
            else
                str=strOrID;
            end
