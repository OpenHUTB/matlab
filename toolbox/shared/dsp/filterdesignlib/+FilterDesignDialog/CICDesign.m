classdef(CaseInsensitiveProperties)CICDesign<FilterDesignDialog.AbstractDesign




    properties(AbortSet,SetObservable,GetObservable)

        DifferentialDelay='1';

        Fpass='0.01';

        Astop='60';
    end


    methods
        function this=CICDesign(varargin)


            this.VariableName=uiservices.getVariableName('Hcic');
            this.FilterType='Decimator';
            if~isempty(varargin)
                set(this,varargin{:});
            end

            this.FDesign=fdesign.decimator(2,'cic');
            updateMethod(this);


            this.LastAppliedState=getState(this);
            this.LastAppliedSpecs=getSpecs(this);


        end

    end

    methods
        function set.DifferentialDelay(obj,value)

            validateattributes(value,{'char'},{'row'},'','DifferentialDelay')
            obj.DifferentialDelay=value;
        end

        function set.Fpass(obj,value)

            validateattributes(value,{'char'},{'row'},'','Fpass')
            obj.Fpass=value;
        end

        function set.Astop(obj,value)

            validateattributes(value,{'char'},{'row'},'','Astop')
            obj.Astop=value;
        end

    end

    methods

        function[Hd,same]=design(this)



            Hd=this.LastAppliedFilter;

            same=false;

            if~isempty(Hd)
                same=true;
                applySettings(this.FixedPoint,Hd);
                return;
            end




            laState=this.LastAppliedState;

            specs=getSpecs(this,laState);
            oldSpecs=this.LastAppliedSpecs;
            if isequal(specs,oldSpecs)
                same=true;
            end

            hfdesign=getFDesign(this,laState);



            w=warning('off','dsp:fdesign:basecatalog:UseSystemObjectForMultirateDesigns');
            restoreWarn=onCleanup(@()warning(w));






            if isSystemObjectDesign(this)
                Hd=design(hfdesign,SystemObject=true);
            else

                allowLegacyFilt=strcmpi(this.OperatingMode,'Simulink');
                Hd=design(hfdesign,AllowLegacyFilters=allowLegacyFilt);
            end

            applySettings(this.FixedPoint,Hd);

            set(this,'LastAppliedFilter',Hd,...
            'LastAppliedSpecs',specs);


        end


        function designOptions=getDesignOptions(~,varargin)





            designOptions={};


        end


        function dialogTitle=getDialogTitle(this)




            if strcmpi(this.OperatingMode,'Simulink')
                dialogTitle=FilterDesignDialog.message('CICFilter');
            else
                dialogTitle=FilterDesignDialog.message('CICDesign');
            end


        end


        function hfdesign=getFDesign(this,laState)




            if nargin<2
                laState=get(this,'LastAppliedState');
            end


            setupFDesign(this,laState);


            hfdesign=get(this,'FDesign');


        end


        function fspecs=getFrequencySpecsFrame(this)



            items=getFrequencyUnitsWidgets(this,3);

            [fpass_lbl,fpass]=getWidgetSchema(this,'Fpass',FilterDesignDialog.message('Fpass'),...
            'edit',4,1);
            items=[items,{fpass_lbl,fpass}];

            fspecs.Name=FilterDesignDialog.message('freqspecs');
            fspecs.Type='group';
            fspecs.Items=items;
            fspecs.LayoutGrid=[4,4];
            fspecs.RowStretch=[0,0,0,1];
            fspecs.ColStretch=[0,1,0,1];
            fspecs.Tag='FreqSpecsGroup';


        end


        function headerFrame=getHeaderFrame(this)



            [ftype_lbl,ftype]=getWidgetSchema(this,'FilterType',...
            FilterDesignDialog.message('filttype'),...
            'combobox',1,1);

            options={'Decimator','Interpolator'};
            ftype.Entries=FilterDesignDialog.message(options);
            ftype.DialogRefresh=true;

            ftype.ObjectMethod='selectComboboxEntry';
            ftype.MethodArgs={'%dialog','%value','FilterType',options};
            ftype.ArgDataTypes={'handle','mxArray','string','mxArray'};



            ftype.Mode=false;



            ftype=rmfield(ftype,'ObjectProperty');


            indx=find(strcmp(options,this.FilterType));
            if~isempty(indx)
                ftype.Value=indx-1;
            end

            [factor_lbl,factor]=getWidgetSchema(this,'Factor',...
            FilterDesignDialog.message('Factor'),...
            'edit',1,3);

            [ddelay_lbl,ddelay]=getWidgetSchema(this,'DifferentialDelay',...
            FilterDesignDialog.message('DifferentialDelay'),'edit',2,1);

            items={ftype_lbl,ftype,factor_lbl,factor,ddelay_lbl,ddelay};

            headerFrame.Type='group';
            headerFrame.Name=FilterDesignDialog.message('filtspecs');

            headerFrame.Items=items;
            headerFrame.LayoutGrid=[3,4];
            headerFrame.ColStretch=[0,1,0,1];
            headerFrame.Tag='FilterSpecsGroup';


        end


        function helpFrame=getHelpFrame(this)




            helptext.Type='text';
            helptext.Name=FilterDesignDialog.message('CICDesignHelpTxt');
            helptext.Tag='HelpText';
            helptext.WordWrap=true;

            helpFrame.Type='group';
            helpFrame.Name=getDialogTitle(this);
            helpFrame.Items={helptext};
            helpFrame.Tag='HelpFrame';


        end


        function Frame=getImplementationFrame(this)



            idx=[0,0];
            items=[];

            if strcmpi(this.OperatingMode,'Simulink')


                [items,idx]=addBuildUsingBasicElementsCheckbox(this,idx,items);


                [items,idx]=addFrameProcessing(this,idx,items);


                items=addRateOptions(this,idx,items);

                layoutGrid=[5,4];
            else

                sysobj_chkbox=getSystemObjectWidget(this,idx+1);
                if~isempty(sysobj_chkbox)&&~strcmp(sysobj_chkbox.Tag,'SystemObjectMandatory')

                    items=[items,{sysobj_chkbox}];
                end
                layoutGrid=[2,4];
            end


            Frame.Type='group';
            Frame.Name=FilterDesignDialog.message('implementation');
            Frame.Items=items;
            Frame.LayoutGrid=layoutGrid;
            Frame.ColStretch=[0,1,0,0];
            Frame.Tag='ImplementationGroup';
        end





        function mCodeInfo=getMCodeInfo(this)





            laState=get(this,'LastAppliedState');
            specs=getSpecs(this,laState);

            variables={'D','Fpass','Astop'};
            values={num2str(specs.DifferentialDelay),num2str(specs.Fpass),...
            num2str(specs.Astop)};
            descs={'Differential delay','',''};
            inputs={'D','''Fp,Ast''','Fpass','Astop'};

            mCodeInfo.Variables=variables;
            mCodeInfo.Values=values;
            mCodeInfo.Inputs=inputs;
            mCodeInfo.Descriptions=descs;


        end


        function mspecs=getMagnitudeSpecsFrame(this)



            items=getMagnitudeUnitsWidgets(this,5);

            [fstop_lbl,fstop]=getWidgetSchema(this,'Astop',FilterDesignDialog.message('Astop'),...
            'edit',6,1);
            items={items{:},fstop_lbl,fstop};%#ok<CCAT>

            mspecs.Name=FilterDesignDialog.message('magspecs');
            mspecs.Type='group';
            mspecs.Items=items;
            mspecs.LayoutGrid=[6,4];
            mspecs.RowStretch=[0,0,0,1];
            mspecs.ColStretch=[0,1,0,1];
            mspecs.Tag='MagSpecsGroup';



        end


        function main=getMainFrame(this)



            header=getHeaderFrame(this);
            header.RowSpan=[1,1];
            header.ColSpan=[1,1];

            fspecs=getFrequencySpecsFrame(this);
            fspecs.RowSpan=[2,2];
            fspecs.ColSpan=[1,1];

            mspecs=getMagnitudeSpecsFrame(this);
            mspecs.RowSpan=[3,3];
            mspecs.ColSpan=[1,1];

            main.Type='panel';
            main.Tag='Main';
            implem=getImplementationFrame(this);
            if isempty(implem.Items)

                main.Items={header,fspecs,mspecs};
            else
                implem.RowSpan=[4,4];
                implem.ColSpan=[1,1];
                main.Items={header,fspecs,mspecs,implem};
            end


        end


        function specification=getSpecification(~,~)




            specification='fp,ast';


        end


        function specs=getSpecs(this,varargin)



            if nargin>1&&~isempty(varargin{1})
                source=varargin{1};
            else
                source=this;
            end

            specs.FilterType=source.FilterType;
            specs.Factor=evaluatevars(source.Factor);

            specs.FrequencyUnits=source.FrequencyUnits;
            specs.InputSampleRate=getnum(this,source,'InputSampleRate');

            specs.MagnitudeUnits=this.MagnitudeUnits;

            specs.Factor=evaluatevars(source.Factor);
            specs.DifferentialDelay=evaluatevars(source.DifferentialDelay);
            specs.Fpass=getnum(this,source,'Fpass');
            specs.Astop=evaluatevars(source.Astop);


        end


        function[validStructures,defaultStructure]=getValidStructures(this,~)




            validStructures={this.Structure};
            defaultStructure=this.Structure;

        end


        function flag=isSystemObjectEnabled(~)



            flag=true;


        end


        function b=setGUI(this,Hd)




            b=true;
            hfdesign=getfdesign(Hd);
            if~strcmpi(hfdesign.Response,'cic')
                b=false;
                return;
            end

            set(this,'DifferentialDelay',num2str(hfdesign.DifferentialDelay));

            switch hfdesign.Specification
            case 'Fp,Ast'
                set(this,...
                'Fpass',num2str(hfdesign.Fpass),...
                'Astop',num2str(hfdesign.Astop));
            otherwise
                error(message('FilterDesignLib:FilterDesignDialog:CICDesign:setGUI:IncompleteConstraints',hfdesign.Specification));
            end

            abstract_setGUI(this,Hd);


        end


        function designmethod=set_designmethod(~,designmethod)







        end


        function[success,msg]=setupFDesign(this,varargin)




            success=true;
            msg='';

            hd=get(this,'FDesign');

            if strcmpi(this.FilterType,'decimator')
                requiredClass='fdesign.decimator';
                factorProp='DecimationFactor';
            else
                requiredClass='fdesign.interpolator';
                factorProp='InterpolationFactor';
            end

            if~isa(hd,requiredClass)
                hd=feval(requiredClass);%#ok<FVAL>
                set(hd,'Response','CIC');
                set(this,'FDesign',hd);
            end

            if nargin>1&&~isempty(varargin{1})
                source=varargin{1};
            else
                source=this;
            end

            try
                specs=getSpecs(this,source);

                if strncmpi(specs.FrequencyUnits,'normalized',10)
                    normalizefreq(hd);
                else
                    normalizefreq(hd,false,specs.InputSampleRate);
                end

                set(hd,factorProp,specs.Factor);

                setspecs(hd,specs.DifferentialDelay,specs.Fpass,...
                specs.Astop,specs.MagnitudeUnits);
            catch e
                success=false;
                msg=cleanerrormsg(e.message);
            end

        end


        function b=supportsSLFixedPoint(~)




            b=true;


        end


        function thisloadobj(this,s)




            this.DifferentialDelay=s.DifferentialDelay;
            this.Fpass=s.Fpass;
            this.Astop=s.Astop;


        end


        function s=thissaveobj(this,s)




            s.DifferentialDelay=this.DifferentialDelay;
            s.Fpass=this.Fpass;
            s.Astop=this.Astop;


        end

    end


    methods(Hidden)

        function updateStructure(this)




            if strcmpi(this.FilterType,'decimator')
                structtype='cicdecim';
            else
                structtype='cicinterp';
            end

            set(this,'Structure',structtype);


        end

        function[items,idx]=addBuildUsingBasicElementsCheckbox(this,idx,items)


            str='build';
            idx=idx+1;
            build.Name=FilterDesignDialog.message(str);
            build.Type='checkbox';
            build.Source=this;
            build.Tag='BuildUsingBasicElements';
            build.RowSpan=idx;
            build.ColSpan=[1,2];
            build.Value=this.BuildUsingBasicElements;
            build.DialogRefresh=true;



            build.Mode=false;
            build.ObjectMethod='setCheckboxValue';
            build.MethodArgs={'BuildUsingBasicElements','%value'};
            build.ArgDataTypes={'string','bool'};

            items=[items,{build}];
        end



        function[items,idx]=addFrameProcessing(this,idx,items)


            idx=idx+1;
            [inProcmode_lbl,inProcmode]=getWidgetSchema(this,'InputProcessing',...
            FilterDesignDialog.message('inputprocessing'),...
            'combobox',idx,1);
            inprocvalidOps=this.InputProcessingSet;



            if this.BuildUsingBasicElements

                inprocvalidOps=inprocvalidOps(2);
                if strcmp(this.InputProcessing,'columnsaschannels')


                    this.InputProcessing='elementsaschannels';
                end
            elseif strcmpi(this.FilterType,'interpolator')

                inprocvalidOps=inprocvalidOps(1:2);
            end
            inProcmode=setcombobox(inProcmode,inprocvalidOps,...
            'InputProcessing',this.InputProcessing);
            inProcmode.DialogRefresh=true;


            if(this.BuildUsingBasicElements||...
                strcmpi(this.FilterType,'interpolator'))
                items=[items,{inProcmode_lbl,inProcmode}];
            end
        end




        function[items,idx]=addRateOptions(this,idx,items)

            idx=idx+1;
            [rate_lbl,rate]=getWidgetSchema(this,'RateOption',...
            FilterDesignDialog.message('rateoption'),...
            'combobox',idx,1);
            ratevalidOps=this.RateOptionSet;






            if this.BuildUsingBasicElements

                this.RateOption='allowmultirate';
                ratevalidOps=ratevalidOps(2);
            elseif strcmpi(this.FilterType,'interpolator')&&...
                strcmpi(this.InputProcessing,'columnsaschannels')

                this.RateOption='enforcesinglerate';
                ratevalidOps=ratevalidOps(1);
            elseif strcmpi(this.FilterType,'decimator')


                if strcmp(this.RateOption,'allowmultirate')
                    this.InputProcessing='elementsaschannels';
                else
                    this.InputProcessing='columnsaschannels';
                end
            end

            rate=setcombobox(rate,ratevalidOps,'RateOption',this.RateOption);
            rate.DialogRefresh=true;
            items=[items,{rate_lbl,rate}];
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
