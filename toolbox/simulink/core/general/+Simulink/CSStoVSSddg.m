classdef CSStoVSSddg<handle
    properties(SetObservable=true)
        blockH=0.0;
        intVar=1;
        mytableData=[];
        members=[];
        rows=0;
    end

    methods

        function varType=getPropDataType(obj,varName)

            switch(varName)
            case 'blockH'
                varType='double';
            case 'intVar'
                varType='int';

            otherwise
                varType='other';
            end
        end


        function dlgstruct=getDialogSchema(obj)


            descText.Name=DAStudio.message('Simulink:Variants:CSStoVSSGUIdescText');
            descText.Type='text';
            descText.WordWrap=true;


            descGroup.Type='group';
            descGroup.Name=DAStudio.message('Simulink:Variants:CSStoVSSGUIDescription');
            descGroup.Items={descText};
            descGroup.RowSpan=[1,1];
            descGroup.ColSpan=[1,3];


            memberCheckBox.Type='checkbox';
            memberCheckBox.WidgetId='my_memberblocks_id';
            memberCheckBox.Value=1;
            memberCheckBox.Name=DAStudio.message('Simulink:Variants:CSStoVSSGUICheckBoxName');
            memberCheckBox.Tag='member_block_scheme_tag';


            memberCheckBoxGroup.Type='group';
            memberCheckBoxGroup.Name=DAStudio.message('Simulink:Variants:CSStoVSSGUICheckBoxGroupName');
            memberCheckBoxGroup.Items={memberCheckBox};
            memberCheckBoxGroup.RowSpan=[2,2];
            memberCheckBoxGroup.ColSpan=[1,3];


            tableData=cell(obj.rows,3);


            if(isempty(obj.mytableData))
                for i=1:obj.rows
                    tableData{i,1}=obj.members{i};





                    varObject=obj.members{i};
                    tableData{i,2}=varObject;


                    [variantCondition]=getVariantConditionFromVariantObject(varObject);
                    tableData{i,3}=variantCondition;
                end
                obj.mytableData=tableData;
            else
                tableData=obj.mytableData;
            end

            variantTable.Type='table';
            variantTable.Tag='varobj_table_tag';
            variantTable.WidgetId='my_table_widgetid';
            variantTable.Size=[obj.rows,3];
            variantTable.Data=tableData;

            variantTable.HeaderVisibility=[0,1];
            variantTable.ColHeader={DAStudio.message('Simulink:dialog:SubsystemVarTableCol0'),...
            DAStudio.message('Simulink:dialog:SubsystemVarTableCol1'),...
            DAStudio.message('Simulink:dialog:SubsystemVarTableCol2')};

            variantTable.Editable=1;
            variantTable.ReadOnlyColumns=[0,2];
            variantTable.SelectionBehavior='Row';
            variantTable.Enabled=1;
            variantTable.DialogRefresh=1;
            variantTable.ValueChangedCallback=@onTableValueChange;


            variantGroup.Type='group';
            variantGroup.Name=DAStudio.message('Simulink:Variants:CSStoVSSGUIVariantGroupName');
            variantGroup.Items={variantTable};
            variantGroup.RowSpan=[3,3];
            variantGroup.ColSpan=[1,3];
            variantGroup.LayoutGrid=[1,1];
            variantGroup.Tag='variantgroup_tag';


            dlgstruct.DialogTitle=[DAStudio.message('Simulink:Variants:CSStoVSSGUITitle'),get_param(obj.blockH,'Name')];
            dlgstruct.Items={descGroup,memberCheckBoxGroup,variantGroup};
            dlgstruct.StandaloneButtonSet={'Ok','Cancel','Help'};
            dlgstruct.CloseCallback='Simulink.CSStoVSSddg.CSStoVSSCBInPlace';
            dlgstruct.CloseArgs={'%dialog','%closeaction'};
            dlgstruct.HelpMethod='helpview';
            dlgstruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],'css2vss'};
        end

    end



    methods(Access='protected')
        function obj=CSStoVSSddg(blockH)
            obj.blockH=blockH;

            m=get_param(obj.blockH,'MemberBlocks');
            m1=regexprep(m,'\n',' ');
            if~isempty(m1)
                membersList=textscan(m1,'%s','delimiter',',');
                membersList=cellstr(membersList{1});
                membersN=length(membersList);
                obj.rows=membersN;
                obj.members=membersList;
            end
        end
    end






    methods(Static=true)

        function ui=Create(blockH)

            [dialogFound,~]=SearchForOpenDialogsforBlock(blockH);

            if(~dialogFound)
                dlgObj=Simulink.CSStoVSSddg(blockH);
                ui=DAStudio.Dialog(dlgObj);
            end
        end



        function CSStoVSSCBInPlace(dialog,action)

            if(strcmp(action,'ok'))
                sourceObj=dialog.getSource;
                tableData=sourceObj.mytableData;
                blockh=sourceObj.blockH;


                memberAddition=dialog.getWidgetValue('member_block_scheme_tag');


                varObjects=tableData(:,2);


                ME='';
                try
                    get_param(blockh,'Object');
                catch ME
                end

                try
                    if(isempty(ME))

                        CSStoVSSStage=Simulink.output.Stage(DAStudio.message('Simulink:Variants:CSStoVSSConversionStage'),...
                        'ModelName',get_param(bdroot(blockh),'Name'),'UIMode',true);

                        slInternal('ConvertToVariantSubsystem',blockh,memberAddition,varObjects);

                        clear CSStoVSSStage;
                    end
                catch ME
                end
            end
        end


    end
end





function onTableValueChange(d,r,c,val)


    r=r+1;
    c=c+1;
    obj=d.getSource;

    obj.mytableData{r,c}=val;

    d.setTableItemValue('varobj_table_tag',r,c,obj.mytableData{r,c});



    [varObjectCondition]=getVariantConditionFromVariantObject(val);
    if~isempty(varObjectCondition)
        obj.mytableData{r,c+1}=varObjectCondition;
        d.setTableItemValue('varobj_table_tag',r,c+1,obj.mytableData{r,c+1});
    end


    d.refresh;
end



function[dialogFound,dialogH]=SearchForOpenDialogsforBlock(blockH)

    dialogFound=0;
    dialogH=[];

    openDialogs=DAStudio.ToolRoot.getOpenDialogs;


    for i=1:length(openDialogs)
        ddgSource=openDialogs(i).getSource;


        if(isa(ddgSource,'Simulink.CSStoVSSddg'))


            bH=ddgSource.blockH;
            if(bH==blockH)
                dialogFound=1;
                dialogH=openDialogs(i);
                break;
            end
        end
    end

end




function[variantCondition]=getVariantConditionFromVariantObject(varObject)

    variantCondition='(empty)';

    string_to_check=['exist(''',strtrim(varObject),''')'];
    variantObjectExist=evalin('base',string_to_check);

    if(variantObjectExist==1)
        variantObject=evalin('base',strtrim(varObject));
        if(~isempty(variantObject)&&...
            isa(variantObject,'Simulink.Variant'))
            varObjectInbase=evalin('base',strtrim(varObject));
            if~isempty(varObjectInbase)
                variantCondition=get(varObjectInbase,'Condition');
            end
        end
    end
end
