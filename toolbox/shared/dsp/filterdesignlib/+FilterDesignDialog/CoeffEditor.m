classdef(CaseInsensitiveProperties)CoeffEditor<FilterDesignDialog.AbstractEditor























    properties(Access=protected,SetObservable)

        FilterListener=[];
    end

    properties(SetObservable)

        FilterObject=[];

        CoefficientVector1='';

        CoefficientVector2='';

        CoefficientVector3='';

        CoefficientVector4='';

        PersistentMemory='off';

        States='';
    end


    methods
        function this=CoeffEditor(Hd)


            narginchk(1,1);

            set(this,'FixedPoint',FilterDesignDialog.FixedPoint,...
            'FilterObject',Hd);

        end

    end

    methods
        function set.FilterObject(obj,value)

            validateattributes(value,{'dfilt.basefilter'},{'scalar'},'','FilterObject')
            obj.FilterObject=set_filterobject(obj,value);
        end

        function set.CoefficientVector1(obj,value)

            validateattributes(value,{'char'},{'row'},'','CoefficientVector1')
            obj.CoefficientVector1=value;
        end

        function set.CoefficientVector2(obj,value)

            validateattributes(value,{'char'},{'row'},'','CoefficientVector2')
            obj.CoefficientVector2=value;
        end

        function set.CoefficientVector3(obj,value)

            validateattributes(value,{'char'},{'row'},'','CoefficientVector3')
            obj.CoefficientVector3=value;
        end

        function set.CoefficientVector4(obj,value)

            validateattributes(value,{'char'},{'row'},'','CoefficientVector4')
            obj.CoefficientVector4=value;
        end

        function set.PersistentMemory(obj,value)

            validatestring(value,{'on','off'},'','PersistentMemory')
            obj.PersistentMemory=value;
        end

        function set.States(obj,value)

            validateattributes(value,{'char'},{'row'},'','States')
            obj.States=value;
        end

        function set.FilterListener(obj,value)

            validateattributes(value,{'handle.listener'},{'scalar'},'','FilterListener')
            obj.FilterListener=value;
        end

    end

    methods

        function dlg=getDialogSchema(this,~)





            helpframe=getHelpFrame;
            helpframe.RowSpan=[1,1];
            helpframe.ColSpan=[1,1];


            editframe=getEditFrame(this);
            fixpt=getFixedPointTab(this);

            tab.Type='tab';
            tab.Tabs={editframe,fixpt};
            tab.RowSpan=[2,2];
            tab.ColSpan=[1,1];
            tab.Tag='TabPanel';
            tab.ActiveTab=this.ActiveTab;
            tab.TabChangedCallback='FilterDesignDialog.TabChangedCallback';

            dlg.DialogTitle='Coefficient Editor';
            dlg.Items={helpframe,tab};

            dlg.PreApplyMethod='preApply';
            dlg.PreApplyArgs={'%dialog'};
            dlg.PreApplyArgsDT={'handle','handle'};
        end





        function[b,str]=preApply(this,hDlg)%#ok<INUSD>




            b=true;
            str='';

            Hd=get(this,'FilterObject');

            names=coefficientnames(Hd);

            oldValues=get(Hd,names);
            try
                values=cell(size(names));
                for indx=1:length(names)
                    values{indx}=evaluatevars(get(this,sprintf('CoefficientVector%d',indx)));
                end

                pMem=get(this,'PersistentMemory');

                if strcmpi(pMem,'on')
                    states=evaluatevars(get(this,'States'));
                end

                set(Hd,names,values);
                set(Hd,'PersistentMemory',strcmpi(pMem,'on'));

                if strcmpi(pMem,'on')
                    set(Hd,'States',states);
                end

                applySettings(this.FixedPoint,Hd);
            catch e
                b=false;
                str=cleanerrormsg(e.message);
                set(Hd,names,oldValues);
            end


        end


        function Hd=set_filterobject(this,Hd)




            names=coefficientnames(Hd);
            for indx=1:length(names)
                p(indx)=Hd.findprop(names{indx});%#ok<AGROW>
            end

            p(end+1)=Hd.findprop('PersistentMemory');
            p(end+1)=Hd.findprop('States');

            l=handle.listener(Hd,p,'PropertyPostSet',...
            @(h,ed)updateCoefficients(this,Hd));
            set(this,'FilterListener',l);

            updateCoefficients(this,Hd);

            [~,cls]=strtok(class(Hd),'.');
            cls(1)=[];

            set(this.FixedPoint,'Structure',cls);
            updateSettings(this.FixedPoint,Hd);
        end




    end

    methods(Hidden)
        function editFrame=getEditFrame(this)

            Hd=get(this,'FilterObject');



            names=coefficientnames(Hd);

            editFrame.Items={};
            editFrame.LayoutGrid=[length(names)+3,2];

            for indx=1:length(names)

                propname=sprintf('CoefficientVector%d',indx);



                editlabel.Type='text';
                editlabel.Name=sprintf('%s: ',interspace(names{indx}));
                editlabel.RowSpan=[indx,indx];
                editlabel.ColSpan=[1,1];
                editlabel.Tag=[propname,'_label'];


                editbox.Type='edit';
                editbox.ObjectProperty=propname;
                editbox.RowSpan=[indx,indx];
                editbox.ColSpan=[2,2];
                editbox.Tag=propname;
                editbox.Source=this;
                editbox.Mode=true;

                editFrame.Items=[editFrame.Items(:)',{editlabel},{editbox}];
            end

            pMemory.Type='checkbox';
            pMemory.Name='Persistent memory';
            pMemory.RowSpan=[length(names)+1,length(names)+1];
            pMemory.ColSpan=[1,2];
            pMemory.ObjectProperty='PersistentMemory';
            pMemory.Tag='PersistentMemory';
            pMemory.Mode=true;
            pMemory.DialogRefresh=true;

            stateslabel.Type='text';
            stateslabel.Name='States: ';
            stateslabel.RowSpan=[length(names)+2,length(names)+2];
            stateslabel.ColSpan=[1,1];

            statesedit.Type='edit';
            statesedit.RowSpan=[length(names)+2,length(names)+2];
            statesedit.ColSpan=[2,2];
            statesedit.ObjectProperty='States';
            statesedit.Tag='States';
            statesedit.Mode=true;

            stateslabel.Enabled=strcmpi(this.PersistentMemory,'on');
            statesedit.Enabled=strcmpi(this.PersistentMemory,'on');

            editFrame.Items=[editFrame.Items(:)',{pMemory},{stateslabel},{statesedit}];
            editFrame.Name='Coefficients';
            editFrame.RowStretch=[zeros(1,length(names)+2),1];
        end



        function fixpt=getFixedPointTab(this)

            h=get(this,'FixedPoint');

            items={getDialogSchemaStruct(h)};

            fixpt.Name='Fixed-point';
            fixpt.Items=items;
            fixpt.Tag='FixedPointTab';
        end


        function updateCoefficients(this,Hd)

            names=coefficientnames(Hd);
            values=get(Hd,names);

            props=sprintf('CoefficientVector%d\n',1:length(names));
            props(end)=[];
            props=cellstr(props);

            for indx=1:length(values)
                values{indx}=mat2str(values{indx});
            end

            set(this,props,values);

            if Hd.PersistentMemory
                pMem='on';
            else
                pMem='off';
            end

            set(this,'PersistentMemory',pMem,'States',mat2str(get(Hd,'States')));
        end

    end

end






function helpFrame=getHelpFrame()

    helptext.Type='text';
    helptext.Name='We need to add help here';
    helptext.Tag='HelpText';

    helpFrame.Type='group';
    helpFrame.Name='Coefficient Editor';
    helpFrame.Items={helptext};
    helpFrame.Tag='HelpFrame';
end




