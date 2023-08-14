classdef(CaseInsensitiveProperties)AudioWeightingDesign<FilterDesignDialog.AbstractDesign




    properties

        WeightingClass='1';

        Type='A';
    end

    properties(Hidden,Constant)

        TypeSet={'A','C','Cmessage','ITUR4684','ITUT041'}
        TypeEntries={FilterDesignDialog.message('a'),...
        FilterDesignDialog.message('c'),...
        FilterDesignDialog.message('cmessage'),...
        FilterDesignDialog.message('itur4684'),...
        FilterDesignDialog.message('itut041'),...
        FilterDesignDialog.message('ansis142'),...
        FilterDesignDialog.message('bell41009')};
    end


    methods
        function this=AudioWeightingDesign(varargin)

            w=warning('off','dsp:fdesign:basecatalog:octave_NotSupported');
            restoreWarn=onCleanup(@()warning(w));
            this.VariableName=uiservices.getVariableName('Haw');
            this.FrequencyUnits='Hz';
            this.InputSampleRate='48000';
            this.ImpulseResponse='IIR';
            if~isempty(varargin)
                set(this,varargin{:});
            end

            this.FDesign=fdesign.audioweighting;
            updateMethod(this);


            this.LastAppliedState=getState(this);
            this.LastAppliedSpecs=getSpecs(this);
            this.LastAppliedDesignOpts=getDesignOptions(this);
        end

    end

    methods
        function set.WeightingClass(obj,value)

            validateattributes(value,{'char'},{'row'},'','WeightingClass')
            obj.WeightingClass=value;
        end

        function set.Type(obj,value)

            value=validatestring(value,obj.TypeSet,'','Type');
            obj.Type=value;
        end

    end

    methods

        function dialogTitle=getDialogTitle(this)



            if strcmpi(this.OperatingMode,'Simulink')
                dialogTitle='Audio Weighting Filter';
            else
                dialogTitle=FilterDesignDialog.message('AudioWeightingDesign');
            end


        end


        function helpFrame=getHelpFrame(this)



            helptext.Type='text';
            helptext.Name=FilterDesignDialog.message('AudioWeightingDesignHelpTxt');
            helptext.Tag='HelpText';
            helptext.WordWrap=true;

            helpFrame.Type='group';
            helpFrame.Name=getDialogTitle(this);
            helpFrame.Items={helptext};
            helpFrame.Tag='HelpFrame';


        end


        function[inProcmode_lbl,inProcmode]=getInputProcessingFrame(this,row)




            [inProcmode_lbl,inProcmode]=getWidgetSchema(this,'InputProcessing',...
            FilterDesignDialog.message('inputprocessing'),...
            'combobox',row,1);
            inprocvalidOps=this.InputProcessingSet;

            if this.BuildUsingBasicElements

                if strcmp(this.ImpulseResponse,'IIR')

                    inprocvalidOps=inprocvalidOps(2);
                    if strcmp(this.InputProcessing,'columnsaschannels')


                        this.InputProcessing='elementsaschannels';
                    end
                end
            end

            inProcmode=setcombobox(inProcmode,inprocvalidOps,'InputProcessing',this.InputProcessing);
            inProcmode.DialogRefresh=true;
        end




        function mCodeInfo=getMCodeInfo(this)



            laState=get(this,'LastAppliedState');
            specs=getSpecs(this,laState);

            variables={'WT'};
            values={['''',specs.Type,'''']};

            descs={'Weighting type'};

            if any(strcmpi(laState.Type,{'a','c'}))
                inputs={'''WT,Class''','WT','Class'};
                variables=[variables,{'Class'}];
                values=[values,{num2str(specs.WeightingClass)}];
                descs=[descs,{'Class'}];
            else
                inputs={'''WT''','WT'};
            end

            mCodeInfo.Variables=variables;
            mCodeInfo.Values=values;
            mCodeInfo.Inputs=inputs;
            mCodeInfo.Descriptions=descs;


        end


        function main=getMainFrame(this)




            [wtype_lbl,wtype]=getWidgetSchema(this,'Type',...
            FilterDesignDialog.message('weighttype'),'combobox',1,1);
            wtype.Entries={...
            FilterDesignDialog.message('a'),...
            FilterDesignDialog.message('c'),...
            FilterDesignDialog.message('cmessage'),...
            FilterDesignDialog.message('itur4684'),...
            FilterDesignDialog.message('itut041')};
            wtype.DialogRefresh=true;

            options={'a','c','cmessage','itur4684','itut041'};
            wtype.ObjectMethod='selectComboboxEntryType';
            wtype.MethodArgs={'%dialog','%value','Type',options};
            wtype.ArgDataTypes={'handle','mxArray','string','mxArray'};
            wtype.Mode=false;
            wtype=rmfield(wtype,'ObjectProperty');


            indx=find(strcmpi(options,this.Type));
            if~isempty(indx)
                wtype.Value=indx-1;
            end


            if any(strcmp(this.Type,{'A','C'}))
                [class_lbl,class]=getWidgetSchema(this,'WeightingClass',...
                FilterDesignDialog.message('class'),'combobox',1,3);
                class.Entries={'1','2'};
                class.DialogRefresh=true;
                classItems={class_lbl,class};
            else
                classItems={};
            end


            [irtype_lbl,irtype]=getWidgetSchema(this,'ImpulseResponse',...
            FilterDesignDialog.message('impresp'),'combobox',2,1);
            irtype.Entries={...
            FilterDesignDialog.message('fir'),...
            FilterDesignDialog.message('iir')};
            irtype.DialogRefresh=true;

            if any(strcmp(this.Type,{'A','C'}))
                this.ImpulseResponse='IIR';
                irtype.Enabled=false;
            elseif strcmp(this.Type,'ITUT041')
                this.ImpulseResponse='FIR';
                irtype.Enabled=false;
            else
                irtype.ObjectProperty='ImpulseResponse';
                irtype.Enabled=true;
            end


            frequnits=getFrequencyUnitsWidgets(this,3);
            frequnits{2}.DialogRefresh=true;
            frequnits{2}.Entries=frequnits{2}.Entries(2:end);

            freqOpts=this.FrequencyUnitsSet;
            freqOpts=freqOpts(2:end);

            defaultindx=find(strcmpi(freqOpts,this.FrequencyUnits));
            if~isempty(defaultindx)
                frequnits{2}.Value=defaultindx-1;
            end
            frequnits{2}.ObjectMethod='selectComboboxEntry';
            frequnits{2}.MethodArgs={'%dialog','%value','FrequencyUnits',freqOpts};
            frequnits{2}.ArgDataTypes={'handle','mxArray','string','mxArray'};



            frequnits{2}.Mode=false;

            frequnits{4}.DialogRefresh=true;


            items={wtype_lbl,wtype,classItems{:},irtype_lbl,irtype,frequnits{:}};%#ok<*CCAT>

            fspecs.Type='group';
            fspecs.Name=FilterDesignDialog.message('filtspecs');
            fspecs.Items=items;
            fspecs.LayoutGrid=[3,4];
            fspecs.ColStretch=[0,1,0,1];
            fspecs.RowSpan=[1,1];
            fspecs.ColSpan=[1,1];
            fspecs.Tag='MainGroup';

            design=getDesignMethodFrame(this);
            design.RowSpan=[2,2];
            design.ColSpan=[1,1];

            main.Type='panel';
            implem=getImplementationFrame(this);
            implem.RowSpan=[3,3];
            implem.ColSpan=[1,1];
            main.Items={fspecs,design,implem};


        end


        function specification=getSpecification(this,laState)



            if nargin<2
                laState=this;
            end

            switch lower(laState.Type)
            case{'a','c'}
                specification='wt,class';
            otherwise
                specification='wt';
            end



        end


        function specs=getSpecs(this,varargin)



            if nargin>1&&~isempty(varargin{1})
                source=varargin{1};
            else
                source=this;
            end

            specs.FilterType=source.FilterType;
            specs.Factor=evaluatevars(source.Factor);
            specs.Order=evaluatevars(source.Order);
            specs.Scale=strcmpi(source.Scale,'on');
            specs.ForceLeadingNumerator=strcmpi(source.ForceLeadingNumerator,'on');
            specs.FrequencyUnits=source.FrequencyUnits;
            specs.InputSampleRate=getnum(this,source,'InputSampleRate');
            specs.Type=source.Type;
            specs.WeightingClass=evaluatevars(source.WeightingClass);


        end


        function selectComboboxEntryType(this,~,indx,prop,options)



            set(this,prop,options{indx+1});

            updateMethod(this)



        end


        function b=setGUI(this,Hd)



            b=true;

            hfdesign=getfdesign(Hd);
            if~strcmp(get(hfdesign,'Response'),'Audio Weighting')
                b=false;
                return;
            end

            switch hfdesign.Specification
            case 'WT,Class'
                set(this,'Type',hfdesign.WeightingType,'WeightingClass',num2str(hfdesign.Class));
            otherwise
                set(this,'Type',hfdesign.WeightingType);
            end

            abstract_setGUI(this,Hd);


        end


        function set_impulseresponse(this,~)



            updateMethod(this);


        end


        function[success,msg]=setupFDesign(this,varargin)



            success=true;
            msg='';

            hd=get(this,'FDesign');

            if nargin>1&&~isempty(varargin{1})
                source=varargin{1};
            else
                source=this;
            end

            spec=getSpecification(this,source);



            setSpecsSafely(this,hd,spec);

            try
                specs=getSpecs(this,source);

                normalizefreq(hd,false,specs.InputSampleRate);

                switch spec
                case 'wt,class'
                    set(hd,'WeightingType',specs.Type,'Class',specs.WeightingClass);
                otherwise
                    set(hd,'WeightingType',specs.Type);
                end

            catch e
                success=false;
                msg=cleanerrormsg(e.message);
            end


        end


        function thisloadobj(this,s)



            this.Type=s.Type;
            this.WeightingClass=s.WeightingClass;


        end


        function s=thissaveobj(this,s)



            s.Type=this.Type;
            s.WeightingClass=this.WeightingClass;


        end

    end

end

function propmode=setcombobox(propmode,propvalidOps,prop,thisprop)
    propmode.Entries=FilterDesignDialog.message(propvalidOps);
    propmode.Value=find(strcmpi(propvalidOps,thisprop))-1;
    propmode.ObjectMethod='selectComboboxEntry';
    propmode.MethodArgs={'%dialog','%value',prop,propvalidOps};
    propmode.ArgDataTypes={'handle','mxArray','string','mxArray'};



    propmode.Mode=false;



    propmode=rmfield(propmode,'ObjectProperty');
end


