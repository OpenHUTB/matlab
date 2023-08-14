classdef(CaseInsensitiveProperties)OctaveDesign<FilterDesignDialog.AbstractDesign




    properties(Access=protected,AbortSet,SetObservable,GetObservable)

        FrequencyUnitsListener=[];
    end

    properties(AbortSet,SetObservable,GetObservable)

        BandsPerOctave='1';

        F0='1000';
    end


    methods
        function this=OctaveDesign(varargin)

            w=warning('off','dsp:fdesign:basecatalog:octave_NotSupported');
            restoreWarn=onCleanup(@()warning(w));

            this.VariableName=uiservices.getVariableName('Hoct');
            this.FrequencyUnits='Hz';
            this.InputSampleRate='48000';
            this.OrderMode='Specify';
            this.Order='6';
            this.ImpulseResponse='IIR';

            if~isempty(varargin)
                set(this,varargin{:});
            end

            this.FDesign=fdesign.octave;
            updateMethod(this);


            this.LastAppliedState=getState(this);
            this.LastAppliedSpecs=getSpecs(this);
            this.LastAppliedDesignOpts=getDesignOptions(this);

        end




    end

    methods
        function set.BandsPerOctave(obj,value)

            validateattributes(value,{'char'},{'row'},'','BandsPerOctave')
            obj.BandsPerOctave=value;
        end

        function set.F0(obj,value)

            validateattributes(value,{'char'},{'row'},'','F0')
            obj.F0=value;
        end

        function set.FrequencyUnitsListener(obj,value)

            validateattributes(value,{'handle.listener'},{'scalar'},'','FrequencyUnitsListener')
            obj.FrequencyUnitsListener=value;
        end

    end

    methods

        function dialogTitle=getDialogTitle(this)




            if strcmpi(this.OperatingMode,'Simulink')
                dialogTitle=FilterDesignDialog.message('OctaveFilter');
            else
                dialogTitle=FilterDesignDialog.message('OctaveDesign');
            end


        end


        function helpFrame=getHelpFrame(this)




            helptext.Type='text';
            helptext.Name=FilterDesignDialog.message('OctaveDesignHelpTxt');
            helptext.Tag='HelpText';
            helptext.WordWrap=true;

            helpFrame.Type='group';
            helpFrame.Name=getDialogTitle(this);
            helpFrame.Items={helptext};
            helpFrame.Tag='HelpFrame';


        end


        function mCodeInfo=getMCodeInfo(this)





            laState=get(this,'LastAppliedState');
            specs=getSpecs(this,laState);

            variables={'B','N','F0'};
            values={num2str(specs.BandsPerOctave),num2str(specs.Order),...
            num2str(specs.F0)};
            descs={'Bands per octave','','Center frequency'};
            inputs={'B','''Class 0''','''N,F0''','N','F0'};

            mCodeInfo.Variables=variables;
            mCodeInfo.Values=values;
            mCodeInfo.Inputs=inputs;
            mCodeInfo.Descriptions=descs;


        end


        function main=getMainFrame(this)




            [order_lbl,order]=getOrderWidgets(this,1,false);


            order.Type='combobox';
            order.Entries={'4','6','8','10'};
            order.Editable=true;


            [bands_lbl,bands]=getWidgetSchema(this,'BandsPerOctave',...
            FilterDesignDialog.message('BandsPerOctave'),'combobox',2,1);


            bands.Editable=true;
            bands.Entries={'1','3','6','12','24'};
            bands.DialogRefresh=true;
            bands.Tunable=false;
            bands_lbl.Tunable=true;

            items=getFrequencyUnitsWidgets(this,3);
            items{2}.DialogRefresh=true;
            items{2}.Entries=items{2}.Entries(2:3);
            items{2}.Tunable=false;

            Freq=this.FrequencyUnitsSet;
            Freq=Freq(2:3);

            defaultindx=find(strcmpi(Freq,this.FrequencyUnits));
            if~isempty(defaultindx)
                items{2}.Value=defaultindx-1;
            end
            items{2}.ObjectMethod='selectComboboxEntry';
            items{2}.MethodArgs={'%dialog','%value','FrequencyUnits',...
            Freq};
            items{2}.ArgDataTypes={'handle','mxArray','string','mxArray'};



            items{2}.Mode=false;






            items{4}.DialogRefresh=true;
            items{4}.Tunable=false;



            [centerfreq_lbl,centerfreq]=getWidgetSchema(this,'F0',...
            FilterDesignDialog.message('CenterFrequency'),'combobox',4,1);

            if isfdtbxinstalled


                validFreqs=validfrequencies(getFDesign(this,this));
                entries=cell(1,length(validFreqs));
                for indx=1:length(validFreqs)
                    entries{indx}=num2str(validFreqs(indx),5);
                end
            else
                entries={'1000'};
            end


            entries=convertfrequnits(entries,'Hz',this.FrequencyUnits);

            centerfreq.Editable=true;
            centerfreq.Entries=entries;
            centerfreq.Tunable=false;

            centerfreq_lbl.Tunable=true;

            items={bands_lbl,bands,order_lbl,order,items{:},centerfreq_lbl,centerfreq};%#ok<CCAT>

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
            design.Items{2}.Tunable=false;

            main.Type='panel';
            implem=getImplementationFrame(this);
            implem.RowSpan=[3,3];
            implem.ColSpan=[1,1];
            main.Items={fspecs,design,implem};


        end


        function specification=getSpecification(~,~)




            specification='N,F0';


        end


        function specs=getSpecs(this,source)



            if nargin<2
                source=this;
            end

            specs.FilterType=source.FilterType;
            specs.Factor=evaluatevars(source.Factor);
            specs.Order=evaluatevars(source.Order);
            specs.Scale=strcmpi(source.Scale,'on');
            specs.F0=getnum(this,source,'F0');
            specs.ForceLeadingNumerator=strcmpi(source.ForceLeadingNumerator,'on');
            specs.BandsPerOctave=evaluatevars(source.BandsPerOctave);
            specs.FrequencyUnits=source.FrequencyUnits;
            specs.InputSampleRate=getnum(this,source,'InputSampleRate');


        end


        function b=setGUI(this,Hd)



            b=true;

            hfdesign=getfdesign(Hd);
            if~strncmp(get(hfdesign,'Response'),'Octave and Fractional Octave',28)
                b=false;
                return;
            end

            set(this,'BandsPerOctave',num2str(hfdesign.BandsPerOctave),...
            'Order',num2str(hfdesign.FilterOrder),...
            'F0',num2str(hfdesign.F0));

            abstract_setGUI(this,Hd);


        end


        function[success,msg]=setupFDesign(this,varargin)




            success=true;
            msg='';

            if nargin>1&&~isempty(varargin{1})
                source=varargin{1};
            else
                source=this;
            end

            specs=getSpecs(this,source);

            hfdesign=get(this,'FDesign');

            try
                if strncmpi(source.FrequencyUnits,'normalized',10)
                    normalizefreq(hfdesign);
                else
                    normalizefreq(hfdesign,false,specs.InputSampleRate);
                end

                set(hfdesign,'FilterOrder',specs.Order,...
                'BandsPerOctave',specs.BandsPerOctave);



                vFreqs=validfrequencies(hfdesign);


                m=10.^ceil(4-log10(vFreqs));
                rvFreqs=round(vFreqs.*m)./m;

                indx=find(abs(rvFreqs-specs.F0)<.01);

                if~isempty(indx)
                    specs.F0=vFreqs(indx);
                end

                set(hfdesign,'F0',specs.F0);
            catch e
                success=false;
                msg=cleanerrormsg(e.message);
            end


        end


        function thisloadobj(this,s)




            this.BandsPerOctave=s.BandsPerOctave;
            this.F0=s.F0;


        end


        function s=thissaveobj(this,s)




            s.BandsPerOctave=this.BandsPerOctave;
            s.F0=this.F0;


        end

    end

end

function fix_f0(this,eventData)%#ok<DEFNU>

    oldF0=get(this,'F0');
    oldFU=get(this,'FrequencyUnits');
    newFU=get(eventData,'NewValue');
    newF0=convertfrequnits(oldF0,oldFU,newFU);

    set(this,'F0',newF0);
end


