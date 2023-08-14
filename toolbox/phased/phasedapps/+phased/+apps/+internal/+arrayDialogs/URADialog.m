classdef(Hidden,Sealed)URADialog<handle






    properties(Hidden,SetAccess=private)
Panel
        Width=0
        Height=0
Listeners

SizeLabel
SizeEdit

ElementSpacingLabel
ElementSpacingEdit
ElementSpacingUnits

LatticeLabel
LatticePopup

ArrayNormalLabel
ArrayNormalPopup

TaperTypeLabel

CustomTaperLabel
CustomTaperEdit

RowTaperLabel
RowTaperPopup

CustomRowTaperLabel
CustomRowTaperEdit

RowSideLobeAttenuationLabel
RowSideLobeAttenuationEdit

RowNbarLabel
RowNbarEdit

RowBetaLabel
RowBetaEdit


ColumnTaperLabel
ColumnTaperPopup

ColumnSideLobeAttenuationLabel
ColumnSideLobeAttenuationEdit

ColumnNbarLabel
ColumnNbarEdit

ColumnBetaLabel
ColumnBetaEdit

CustomColumnTaperLabel
CustomColumnTaperEdit

        ArrayDialogTitle=getString(message('phased:apps:arrayapp:ura'));
    end

    properties(Hidden)
TaperTypePopup
    end

    properties(Dependent)
Size
ElementSpacing
ArrayNormal
Lattice
TaperInputType
CustomTaper
RowTaper
RowCustomTaper
RowSideLobeAttenuation
RowNbar
RowBeta
ColumnTaper
ColumnCustomTaper
ColumnSideLobeAttenuation
ColumnNbar
ColumnBeta
    end

    properties(Access=private)
Parent
Layout

        ValidSize=[4,4]
        ValidElementSpacing=[0.5,0.5]
        ValidCustomTaper=1
        ValidRowCustomTaper=1
        ValidRowSideLobeAttenuation=30
        ValidRowNbar=4
        ValidRowBeta=0.5
        ValidColumnCustomTaper=1
        ValidColumnSideLobeAttenuation=30
        ValidColumnNbar=4
        ValidColumnBeta=0.5
        ValidLattice=getString(message('phased:apps:arrayapp:Rectangular'))
        ValidArrayNormal=getString(message('phased:apps:arrayapp:yaxis'))
    end

    methods
        function obj=URADialog(parent)

            obj.Parent=parent;

            createUIControls(obj)
            layoutUIControls(obj)
        end
    end

    methods


        function val=get.Size(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.SizeEdit.String);
            else
                val=evalin('base',obj.SizeEdit.Value);
            end
        end

        function set.Size(obj,val)
            if~isUIFigure(obj.Parent)
                obj.SizeEdit.String=mat2str(val);
            else
                obj.SizeEdit.Value=mat2str(val);
            end
        end


        function val=get.ElementSpacing(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.ElementSpacingEdit.String);
            else
                val=evalin('base',obj.ElementSpacingEdit.Value);
            end
        end

        function set.ElementSpacing(obj,val)
            if~isUIFigure(obj.Parent)
                obj.ElementSpacingEdit.String=mat2str(val);
            else
                obj.ElementSpacingEdit.Value=mat2str(val);
            end
        end


        function val=get.TaperInputType(obj)
            if~isUIFigure(obj.Parent)
                val=obj.TaperTypePopup.String{obj.TaperTypePopup.Value};
            else
                val=obj.TaperTypePopup.Value;
            end
        end

        function set.TaperInputType(obj,str)
            if~isUIFigure(obj.Parent)
                if strcmp(str,getString(message('phased:apps:arrayapp:RowColumnTaper')))
                    obj.TaperTypePopup.Value=1;
                else
                    obj.TaperTypePopup.Value=2;
                end
            else
                if strcmp(str,getString(message('phased:apps:arrayapp:RowColumnTaper')))
                    obj.TaperTypePopup.Value=getString(message('phased:apps:arrayapp:RowColumnTaper'));
                else
                    obj.TaperTypePopup.Value=getString(message('phased:apps:arrayapp:Custom'));
                end
            end
        end


        function val=get.CustomTaper(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.CustomTaperEdit.String);
            else
                val=evalin('base',obj.CustomTaperEdit.Value);
            end
        end

        function set.CustomTaper(obj,val)
            if~isUIFigure(obj.Parent)
                obj.CustomTaperEdit.String=mat2str(val);
            else
                obj.CustomTaperEdit.Value=mat2str(val);
            end
        end


        function val=get.RowTaper(obj)
            if~isUIFigure(obj.Parent)
                val=obj.RowTaperPopup.String{obj.RowTaperPopup.Value};
            else
                val=obj.RowTaperPopup.Value;
            end
        end

        function set.RowTaper(obj,str)
            if~isUIFigure(obj.Parent)
                switch str
                case getString(message('phased:apps:arrayapp:None'))
                    obj.RowTaperPopup.Value=1;
                case getString(message('phased:apps:arrayapp:Hamming'))
                    obj.RowTaperPopup.Value=2;
                case getString(message('phased:apps:arrayapp:Chebyshev'))
                    obj.RowTaperPopup.Value=3;
                case getString(message('phased:apps:arrayapp:Hann'))
                    obj.RowTaperPopup.Value=4;
                case getString(message('phased:apps:arrayapp:Kaiser'))
                    obj.RowTaperPopup.Value=5;
                case getString(message('phased:apps:arrayapp:Taylor'))
                    obj.RowTaperPopup.Value=6;
                case getString(message('phased:apps:arrayapp:Custom'))
                    obj.RowTaperPopup.Value=7;
                end
            else
                switch str
                case getString(message('phased:apps:arrayapp:None'))
                    obj.RowTaperPopup.Value=getString(message('phased:apps:arrayapp:None'));
                case getString(message('phased:apps:arrayapp:Hamming'))
                    obj.RowTaperPopup.Value=getString(message('phased:apps:arrayapp:Hamming'));
                case getString(message('phased:apps:arrayapp:Chebyshev'))
                    obj.RowTaperPopup.Value=getString(message('phased:apps:arrayapp:Chebyshev'));
                case getString(message('phased:apps:arrayapp:Hann'))
                    obj.RowTaperPopup.Value=getString(message('phased:apps:arrayapp:Hann'));
                case getString(message('phased:apps:arrayapp:Kaiser'))
                    obj.RowTaperPopup.Value=getString(message('phased:apps:arrayapp:Kaiser'));
                case getString(message('phased:apps:arrayapp:Taylor'))
                    obj.RowTaperPopup.Value=getString(message('phased:apps:arrayapp:Taylor'));
                case getString(message('phased:apps:arrayapp:Custom'))
                    obj.RowTaperPopup.Value=getString(message('phased:apps:arrayapp:Custom'));
                end
            end
        end


        function val=get.RowSideLobeAttenuation(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.RowSideLobeAttenuationEdit.String);
            else
                val=evalin('base',obj.RowSideLobeAttenuationEdit.Value);
            end
        end

        function set.RowSideLobeAttenuation(obj,val)
            if~isUIFigure(obj.Parent)
                obj.RowSideLobeAttenuationEdit.String=mat2str(val);
            else
                obj.RowSideLobeAttenuationEdit.Value=mat2str(val);
            end
        end


        function val=get.RowNbar(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.RowNbarEdit.String);
            else
                val=evalin('base',obj.RowNbarEdit.Value);
            end
        end

        function set.RowNbar(obj,val)
            if~isUIFigure(obj.Parent)
                obj.RowNbarEdit.String=mat2str(val);
            else
                obj.RowNbarEdit.Value=mat2str(val);
            end
        end


        function val=get.RowBeta(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.RowBetaEdit.String);
            else
                val=evalin('base',obj.RowBetaEdit.Value);
            end
        end

        function set.RowBeta(obj,val)
            if~isUIFigure(obj.Parent)
                obj.RowBetaEdit.String=mat2str(val);
            else
                obj.RowBetaEdit.Value=mat2str(val);
            end
        end

        function val=get.RowCustomTaper(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.CustomRowTaperEdit.String);
            else
                val=evalin('base',obj.CustomRowTaperEdit.Value);
            end
        end

        function set.RowCustomTaper(obj,val)
            if~isUIFigure(obj.Parent)
                obj.CustomRowTaperEdit.String=mat2str(val);
            else
                obj.CustomRowTaperEdit.Value=mat2str(val);
            end
        end



        function val=get.ColumnTaper(obj)
            if~isUIFigure(obj.Parent)
                val=obj.ColumnTaperPopup.String{obj.RowTaperPopup.Value};
            else
                val=obj.ColumnTaperPopup.Value;
            end
        end

        function set.ColumnTaper(obj,str)
            if~isUIFigure(obj.Parent)
                switch str
                case getString(message('phased:apps:arrayapp:None'))
                    obj.ColumnTaperPopup.Value=1;
                case getString(message('phased:apps:arrayapp:Hamming'))
                    obj.ColumnTaperPopup.Value=2;
                case getString(message('phased:apps:arrayapp:Chebyshev'))
                    obj.ColumnTaperPopup.Value=3;
                case getString(message('phased:apps:arrayapp:Hann'))
                    obj.ColumnTaperPopup.Value=4;
                case getString(message('phased:apps:arrayapp:Kaiser'))
                    obj.ColumnTaperPopup.Value=5;
                case getString(message('phased:apps:arrayapp:Taylor'))
                    obj.ColumnTaperPopup.Value=6;
                case getString(message('phased:apps:arrayapp:Custom'))
                    obj.ColumnTaperPopup.Value=7;
                end
            else
                switch str
                case getString(message('phased:apps:arrayapp:None'))
                    obj.ColumnTaperPopup.Value=getString(message('phased:apps:arrayapp:None'));
                case getString(message('phased:apps:arrayapp:Hamming'))
                    obj.ColumnTaperPopup.Value=getString(message('phased:apps:arrayapp:Hamming'));
                case getString(message('phased:apps:arrayapp:Chebyshev'))
                    obj.ColumnTaperPopup.Value=getString(message('phased:apps:arrayapp:Chebyshev'));
                case getString(message('phased:apps:arrayapp:Hann'))
                    obj.ColumnTaperPopup.Value=getString(message('phased:apps:arrayapp:Hann'));
                case getString(message('phased:apps:arrayapp:Kaiser'))
                    obj.ColumnTaperPopup.Value=getString(message('phased:apps:arrayapp:Kaiser'));
                case getString(message('phased:apps:arrayapp:Taylor'))
                    obj.ColumnTaperPopup.Value=getString(message('phased:apps:arrayapp:Taylor'));
                case getString(message('phased:apps:arrayapp:Custom'))
                    obj.ColumnTaperPopup.Value=getString(message('phased:apps:arrayapp:Custom'));
                end
            end
        end


        function val=get.ColumnSideLobeAttenuation(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.ColumnSideLobeAttenuationEdit.String);
            else
                val=evalin('base',obj.ColumnSideLobeAttenuationEdit.Value);
            end
        end

        function set.ColumnSideLobeAttenuation(obj,val)
            if~isUIFigure(obj.Parent)
                obj.ColumnSideLobeAttenuationEdit.String=mat2str(val);
            else
                obj.ColumnSideLobeAttenuationEdit.Value=mat2str(val);
            end
        end


        function val=get.ColumnNbar(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.ColumnNbarEdit.String);
            else
                val=evalin('base',obj.ColumnNbarEdit.Value);
            end
        end

        function set.ColumnNbar(obj,val)
            if~isUIFigure(obj.Parent)
                obj.ColumnNbarEdit.String=mat2str(val);
            else
                obj.ColumnNbarEdit.Value=mat2str(val);
            end
        end


        function val=get.ColumnBeta(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.ColumnBetaEdit.String);
            else
                val=evalin('base',obj.ColumnBetaEdit.Value);
            end
        end

        function set.ColumnBeta(obj,val)
            if~isUIFigure(obj.Parent)
                obj.ColumnBetaEdit.String=mat2str(val);
            else
                obj.ColumnBetaEdit.Value=mat2str(val);
            end
        end

        function val=get.ColumnCustomTaper(obj)
            if~isUIFigure(obj.Parent)
                val=evalin('base',obj.CustomColumnTaperEdit.String);
            else
                val=evalin('base',obj.CustomColumnTaperEdit.Value);
            end
        end

        function set.ColumnCustomTaper(obj,val)
            if~isUIFigure(obj.Parent)
                obj.CustomColumnTaperEdit.String=mat2str(val);
            else
                obj.CustomColumnTaperEdit.Value=mat2str(val);
            end
        end


        function val=get.ArrayNormal(obj)
            if~isUIFigure(obj.Parent)
                val=obj.ArrayNormalPopup.String{obj.ArrayNormalPopup.Value};
            else
                val=obj.ArrayNormalPopup.Value;
            end
        end

        function set.ArrayNormal(obj,str)
            if~isUIFigure(obj.Parent)
                if strcmp(str,...
                    getString(message('phased:apps:arrayapp:xaxis')))
                    obj.ArrayNormalPopup.Value=1;
                elseif strcmp(str,...
                    getString(message('phased:apps:arrayapp:yaxis')))
                    obj.ArrayNormalPopup.Value=2;
                else
                    obj.ArrayNormalPopup.Value=3;
                end
            else
                if strcmp(str,getString(message('phased:apps:arrayapp:xaxis')))
                    obj.ArrayNormalPopup.Value=getString(message('phased:apps:arrayapp:xaxis'));
                elseif strcmp(str,getString(message('phased:apps:arrayapp:yaxis')))
                    obj.ArrayNormalPopup.Value=getString(message('phased:apps:arrayapp:yaxis'));
                else
                    obj.ArrayNormalPopup.Value=getString(message('phased:apps:arrayapp:zaxis'));
                end
            end
        end


        function val=get.Lattice(obj)
            if~isUIFigure(obj.Parent)
                val=obj.LatticePopup.String{obj.LatticePopup.Value};
            else
                val=obj.LatticePopup.Value;
            end
        end

        function set.Lattice(obj,str)
            if~isUIFigure(obj.Parent)
                if strcmp(str,...
                    getString(message('phased:apps:arrayapp:Rectangular')))
                    obj.LatticePopup.Value=1;
                else
                    obj.LatticePopup.Value=2;
                end
            else
                if strcmp(str,getString(message('phased:apps:arrayapp:Rectangular')))
                    obj.LatticePopup.Value=getString(message('phased:apps:arrayapp:Rectangular'));
                else
                    obj.LatticePopup.Value=getString(message('phased:apps:arrayapp:Triangular'));
                end
            end
        end



        function updateArrayObject(obj)

            propSpeed=obj.Parent.App.PropagationSpeed;
            freq=obj.Parent.App.SignalFrequencies(1);

            if obj.Parent.isUsingLambda(obj.ElementSpacingUnits)
                ratio=propSpeed/freq;
            else
                ratio=1;
            end

            elemSpacing=obj.ElementSpacing*ratio;

            if strcmp(obj.TaperInputType,getString(message('phased:apps:arrayapp:RowColumnTaper')))
                rowtapertype=getCurTaperType(obj,obj.RowTaperPopup.Value);
                columntapertype=getCurTaperType(obj,obj.ColumnTaperPopup.Value);

                taperRow=computeTaper(obj,rowtapertype,obj.Size(2),...
                obj.RowSideLobeAttenuation,obj.RowNbar,obj.RowBeta,obj.RowCustomTaper);

                taperColumn=computeTaper(obj,columntapertype,obj.Size(1),...
                obj.ColumnSideLobeAttenuation,obj.ColumnNbar,obj.ColumnBeta,obj.ColumnCustomTaper);

                taper=taperRow*taperColumn.';
                taper=taper.';
            else
                taper=obj.CustomTaper;
            end



            obj.Parent.App.CurrentArray=phased.URA(...
            'Element',obj.Parent.App.CurrentElement,...
            'Size',obj.Size,...
            'ElementSpacing',elemSpacing,...
            'Lattice',obj.Lattice,...
            'ArrayNormal',obj.ArrayNormal,...
            'Taper',taper);
        end

        function validParams=verifyParameters(obj)

            SigFreqs=obj.Parent.ElementDialog.SignalFreq;
            usingLambda=obj.Parent.isUsingLambda(obj.ElementSpacingUnits);


            validParams=checkValidityOfWaveLengthUnits(obj.Parent,usingLambda,SigFreqs);
        end

        function numElem=getNumElements(obj)
            numElem=obj.Size(1)*obj.Size(2);
        end

        function taperType=getCurTaperType(obj,popValue)
            taperType=phased.apps.internal.TaperType.getTaperAtPos(popValue,obj.Parent.App.Container);
        end

        function t=computeTaper(~,tapertype,numElements,...
            sidelobeAttenuation,...
            nbar,...
            beta,...
            customTaper)

            t=tapertype.TaperGetCallback(...
            tapertype,numElements,...
            sidelobeAttenuation,...
            beta,...
            nbar,...
            customTaper);
        end


        function genTaper(~,taperType,sw,wind,numElements,sidelobeAttenuation,nbar,...
            beta,customTaper,customTaperString)

            taperType.GenCodeCallback(taperType,sw,wind,...
            numElements,...
            sidelobeAttenuation,...
            beta,...
            nbar,...
            customTaper,...
            customTaperString);
        end

        function gencode(obj,sw)

            propSpeed=obj.Parent.App.PropagationSpeed;
            freq=obj.Parent.App.SignalFrequencies(1);

            addcr(sw,'% Create a uniform rectangular array');
            if~isUIFigure(obj.Parent)
                addcr(sw,['Array = phased.URA(''Size'',',obj.SizeEdit.String,',...'])
            else
                addcr(sw,['Array = phased.URA(''Size'',',obj.SizeEdit.Value,',...'])
            end
            addcr(sw,['''Lattice'',''',obj.Lattice,''',''ArrayNormal'',''',obj.ArrayNormal,''');'])
            if obj.Parent.isUsingLambda(obj.ElementSpacingUnits)
                ratio=propSpeed/freq;
                addcr(sw,'% The multiplication factor for lambda units to meter conversion')
                addcr(sw,['Array.ElementSpacing = ',mat2str(obj.ElementSpacing),'*',mat2str(ratio),';'])
            else
                addcr(sw,['Array.ElementSpacing = ',mat2str(obj.ElementSpacing),';'])
            end

            if strcmp(obj.TaperInputType,getString(message('phased:apps:arrayapp:RowColumnTaper')))
                rowTaperType=getCurTaperType(obj,obj.RowTaperPopup.Value);
                columnTaperType=getCurTaperType(obj,obj.ColumnTaperPopup.Value);
                if~isUIFigure(obj.Parent)
                    rowTaper=obj.CustomRowTaperEdit.String;
                    colTaper=obj.CustomColumnTaperEdit.String;
                else
                    rowTaper=obj.CustomRowTaperEdit.Value;
                    colTaper=obj.CustomColumnTaperEdit.Value;
                end
                addcr(sw,'% Calculate Row taper')
                genTaper(obj,rowTaperType,sw,'rwind',obj.Size(2),...
                obj.RowSideLobeAttenuation,obj.RowNbar,obj.RowBeta,...
                obj.RowCustomTaper,rowTaper);

                addcr(sw,'% Calculate Column taper')
                genTaper(obj,columnTaperType,sw,'cwind',obj.Size(1),...
                obj.ColumnSideLobeAttenuation,obj.ColumnNbar,...
                obj.ColumnBeta,obj.ColumnCustomTaper,colTaper);

                addcr(sw,'% Calculate taper');
                addcr(sw,'taper = rwind*cwind.'';');
                addcr(sw,'Array.Taper = taper.'';');
            else
                if~isUIFigure(obj.Parent)
                    addcr(sw,['Array.Taper = ',obj.CustomTaperEdit.String,';']);
                else
                    addcr(sw,['Array.Taper = ',obj.CustomTaperEdit.Value,';']);
                end
            end
        end

        function genreport(obj,sw)

            if isa(obj.Parent.App.CurrentArray,'phased.ReplicatedSubarray')
                addcr(sw,'% Subarray Type ......................................... Uniform Rectangular Subarray')
                addcr(sw,['% Size ................................................. ',mat2str(obj.Size)])
                addcr(sw,['% Element Spacing (m) .................................. ',mat2str(obj.ElementSpacing)])
                addcr(sw,['% Subarray Normal ...................................... ',obj.ArrayNormal])
            else
                addcr(sw,'% Array Type ........................................... Uniform Rectangular Array')
                addcr(sw,['% Size ................................................. ',mat2str(obj.Size)])
                addcr(sw,['% Element Spacing (m) .................................. ',mat2str(obj.ElementSpacing)])
                addcr(sw,['% Array Normal ......................................... ',obj.ArrayNormal])
            end
            if strcmp(obj.TaperInputType,getString(message('phased:apps:arrayapp:RowColumnTaper')))
                addcr(sw,['% Row Taper ............................................ ',obj.RowTaper])
                rowTaperType=getCurTaperType(obj,obj.RowTaperPopup.Value);
                switch rowTaperType
                case getString(message('phased:apps:arrayapp:Chebyshev'))
                    addcr(sw,['% Sidelobe Attenuation (dB) ............................ ',mat2str(obj.RowSideLobeAttenuation)]);
                case getString(message('phased:apps:arrayapp:Kaiser'))
                    addcr(sw,['% beta ................................................. ',mat2str(obj.RowBeta)]);
                case getString(message('phased:apps:arrayapp:Taylor'))
                    addcr(sw,['% Sidelobe Attenuation (dB) ............................ ',mat2str(obj.RowSideLobeAttenuation)]);
                    addcr(sw,['% nbar ................................................. ',mat2str(obj.RowNbar)]);
                case getString(message('phased:apps:arrayapp:Custom'))
                    if~isUIFigure(obj.Parent)
                        addcr(sw,['% Custom Taper ......................................... ',obj.CustomRowTaperEdit.String]);
                    else
                        addcr(sw,['% Custom Taper ......................................... ',obj.CustomRowTaperEdit.Value]);
                    end
                end

                addcr(sw,['% Column Taper ......................................... ',obj.ColumnTaper])
                columnTaperType=getCurTaperType(obj,obj.ColumnTaperPopup.Value);
                switch columnTaperType
                case getString(message('phased:apps:arrayapp:Chebyshev'))
                    addcr(sw,['% Sidelobe Attenuation (dB) ............................ ',mat2str(obj.ColumnSideLobeAttenuation)]);
                case getString(message('phased:apps:arrayapp:Kaiser'))
                    addcr(sw,['% beta ................................................. ',mat2str(obj.ColumnBeta)]);
                case getString(message('phased:apps:arrayapp:Taylor'))
                    addcr(sw,['% Sidelobe Attenuation (dB) ............................ ',mat2str(obj.ColumnSideLobeAttenuation)]);
                    addcr(sw,['% nbar ................................................. ',mat2str(obj.ColumnNbar)]);
                case getString(message('phased:apps:arrayapp:Custom'))
                    if~isUIFigure(obj.Parent)
                        addcr(sw,['% Custom Taper ......................................... ',obj.CustomColumnTaperEdit.String]);
                    else
                        addcr(sw,['% Custom Taper ......................................... ',obj.CustomColumnTaperEdit.Value]);
                    end
                end
            else
                if~isUIFigure(obj.Parent)
                    addcr(sw,['% Custom Taper ........................................... ',obj.CustomTaperEdit.String])
                else
                    addcr(sw,['% Custom Taper ........................................... ',obj.CustomTaperEdit.Value])
                end
            end

            addcr(sw,['% Lattice .............................................. ',obj.Lattice])
        end

        function title=assignArrayDialogTitle(obj)

            if obj.Parent.App.IsSubarray
                if strcmp(obj.Parent.AdditionalConfigDialog.SubarrayType,...
                    getString(message('phased:apps:arrayapp:replicatesubarray')))
                    title=[getString(message('phased:apps:arrayapp:subarraygeo')),...
                    ' - ',obj.ArrayDialogTitle];
                else
                    title=[getString(...
                    message('phased:apps:arrayapp:ArrayGeometry')),' - ',...
                    obj.ArrayDialogTitle];
                end
            else
                title=[getString(...
                message('phased:apps:arrayapp:ArrayGeometry')),' - ',...
                obj.ArrayDialogTitle];
            end
        end
    end

    methods(Access=private)
        function createUIControls(obj)

            dialogtitle=assignArrayDialogTitle(obj);
            if~isUIFigure(obj.Parent)
                obj.Panel=obj.Parent.createPanel(obj.Parent.App.ParametersFig,...
                dialogtitle);
            else
                obj.Panel=obj.Parent.createPanel(obj.Parent.Layout,...
                dialogtitle);
            end

            hspacing=3;
            vspacing=6;


            obj.Layout=obj.Parent.createLayout(obj.Panel,...
            vspacing,hspacing,...
            [0,0,0,0,0,0,0,0,0,0,0,0,0,1],[0,1,0]);

            if~isUIFigure(obj.Parent)
                parent=obj.Panel;
            else
                parent=obj.Layout;
            end

            obj.SizeLabel=obj.Parent.createTextLabel(parent,...
            getString(...
            message('phased:apps:arrayapp:Size')));

            obj.SizeEdit=obj.Parent.createEditBox(parent,...
            '[4 4]',getString(...
            message('phased:apps:arrayapp:SizeTT')),...
            'sizeEdit',@(h,e)parameterChanged(obj,e));


            obj.ElementSpacingLabel=obj.Parent.createTextLabel(parent,...
            getString(...
            message('phased:apps:arrayapp:ElementSpacing')));

            obj.ElementSpacingEdit=obj.Parent.createEditBox(parent,...
            '[0.5 0.5]',getString(...
            message('phased:apps:arrayapp:ElementSpacingRTT')),...
            'elementSpacingEdit',@(h,e)parameterChanged(obj,e));

            unitStrings={getString(message('phased:apps:arrayapp:meter')),...
            char(955)};

            obj.ElementSpacingUnits=obj.Parent.createDropDown(parent,...
            unitStrings,1,' ',...
            'elementSpacingUnit',@(h,e)parameterChanged(obj,e));


            obj.ArrayNormalLabel=obj.Parent.createTextLabel(parent,...
            getString(...
            message('phased:apps:arrayapp:ArrayNormal')));

            arrayNormalPopup={getString(message('phased:apps:arrayapp:xaxis')),...
            getString(message('phased:apps:arrayapp:yaxis')),...
            getString(message('phased:apps:arrayapp:zaxis'))};

            obj.ArrayNormalPopup=obj.Parent.createDropDown(parent,...
            arrayNormalPopup,1,...
            getString(message('phased:apps:arrayapp:ArrayNormalTT')),...
            'arrayNormalPopup',@(h,e)parameterChanged(obj,e));


            obj.LatticeLabel=obj.Parent.createTextLabel(parent,...
            getString(...
            message('phased:apps:arrayapp:Lattice')));

            LatticeNames={getString(message('phased:apps:arrayapp:Rectangular')),...
            getString(message('phased:apps:arrayapp:Triangular'))};

            obj.LatticePopup=obj.Parent.createDropDown(parent,...
            LatticeNames,1,...
            getString(...
            message('phased:apps:arrayapp:LatticeTT')),...
            'latticePopup',@(h,e)parameterChanged(obj,e));


            obj.TaperTypeLabel=obj.Parent.createTextLabel(parent,...
            getString(...
            message('phased:apps:arrayapp:Taper')));

            tapertypes={getString(message('phased:apps:arrayapp:RowColumnTaper')),...
            getString(message('phased:apps:arrayapp:Custom'))};

            obj.TaperTypePopup=obj.Parent.createDropDown(parent,...
            tapertypes,1,getString(...
            message('phased:apps:arrayapp:TaperTT')),...
            'taperTypePopup',@(h,e)parameterChanged(obj,e));


            obj.CustomTaperLabel=obj.Parent.createTextLabel(parent,...
            getString(message('phased:apps:arrayapp:CustomTaper')),...
            'off');

            obj.CustomTaperEdit=obj.Parent.createEditBox(parent,...
            '1',getString(message('phased:apps:arrayapp:CustomTaperTT')),...
            'taperEdit',@(h,e)parameterChanged(obj,e),'off');


            obj.RowTaperLabel=obj.Parent.createTextLabel(parent,...
            getString(message('phased:apps:arrayapp:RowTaper')));

            taperpopup=phased.apps.internal.TaperType.names;

            obj.RowTaperPopup=obj.Parent.createDropDown(parent,...
            taperpopup,1,getString(...
            message('phased:apps:arrayapp:RowTaperTT')),...
            'rowTaperPopup',@(h,e)parameterChanged(obj,e));


            obj.RowSideLobeAttenuationLabel=obj.Parent.createTextLabel(...
            parent,[getString(...
            message('phased:apps:arrayapp:SidelobeAttenuation')),...
            ' (',getString(message('phased:apps:arrayapp:dB')),')'],...
            'off');

            obj.RowSideLobeAttenuationEdit=obj.Parent.createEditBox(...
            parent,'30',...
            getString(message('phased:apps:arrayapp:SidelobeLevelTT')),...
            'row_sideLobeEdit',@(h,e)parameterChanged(obj,e),'off');


            obj.RowNbarLabel=obj.Parent.createTextLabel(parent,...
            getString(message('phased:apps:arrayapp:nbar')),...
            'off');

            obj.RowNbarEdit=obj.Parent.createEditBox(parent,...
            '4',getString(message('phased:apps:arrayapp:nbarTaylorTT')),...
            'row_nBarEdit',@(h,e)parameterChanged(obj,e),'off');



            obj.RowBetaLabel=obj.Parent.createTextLabel(parent,...
            getString(message('phased:apps:arrayapp:beta')),...
            'off');

            obj.RowBetaEdit=obj.Parent.createEditBox(parent,...
            '0.5',getString(message('phased:apps:arrayapp:betaKaiserTT')),...
            'row_betaEdit',@(h,e)parameterChanged(obj,e),'off');

            obj.CustomRowTaperLabel=obj.Parent.createTextLabel(parent,...
            getString(message('phased:apps:arrayapp:CustomTaper')),...
            'off');

            obj.CustomRowTaperEdit=obj.Parent.createEditBox(parent,...
            '1',getString(...
            message('phased:apps:arrayapp:CustomTaperTT')),...
            'rowCustomTaperEdit',@(h,e)parameterChanged(obj,e),'off');


            obj.ColumnTaperLabel=obj.Parent.createTextLabel(parent,...
            getString(message('phased:apps:arrayapp:ColumnTaper')));

            taperpopup=phased.apps.internal.TaperType.names;

            obj.ColumnTaperPopup=obj.Parent.createDropDown(parent,...
            taperpopup,1,getString(...
            message('phased:apps:arrayapp:ColumnTaperTT')),...
            'columnTaperPopup',@(h,e)parameterChanged(obj,e));


            obj.ColumnSideLobeAttenuationLabel=obj.Parent.createTextLabel(...
            parent,[getString(...
            message('phased:apps:arrayapp:SidelobeAttenuation')),...
            ' (',getString(message('phased:apps:arrayapp:dB')),')'],...
            'off');

            obj.ColumnSideLobeAttenuationEdit=obj.Parent.createEditBox(...
            parent,'30',...
            getString(message('phased:apps:arrayapp:SidelobeLevelTT')),...
            'column_sideLobeEdit',@(h,e)parameterChanged(obj,e),'off');


            obj.ColumnNbarLabel=obj.Parent.createTextLabel(parent,...
            getString(message('phased:apps:arrayapp:nbar')),...
            'off');

            obj.ColumnNbarEdit=obj.Parent.createEditBox(parent,...
            '4',getString(message('phased:apps:arrayapp:nbarTaylorTT')),...
            'column_nBarEdit',@(h,e)parameterChanged(obj,e),'off');



            obj.ColumnBetaLabel=obj.Parent.createTextLabel(parent,...
            getString(message('phased:apps:arrayapp:beta')),...
            'off');

            obj.ColumnBetaEdit=obj.Parent.createEditBox(parent,...
            '0.5',getString(message('phased:apps:arrayapp:betaKaiserTT')),...
            'column_betaEdit',@(h,e)parameterChanged(obj,e),'off');

            obj.CustomColumnTaperLabel=obj.Parent.createTextLabel(...
            parent,getString(...
            message('phased:apps:arrayapp:CustomTaper')),...
            'off');

            obj.CustomColumnTaperEdit=obj.Parent.createEditBox(...
            parent,'1',...
            getString(...
            message('phased:apps:arrayapp:CustomTaperTT')),...
            'columnCustomTaperEdit',@(h,e)parameterChanged(obj,e),'off');
        end
    end
    methods(Hidden)
        function layoutUIControls(obj)
            if~isUIFigure(obj.Parent)
                hspacing=3;
                vspacing=6;


                obj.Layout=obj.Parent.createLayout(obj.Panel,...
                vspacing,hspacing,...
                [0,0,0,0,0,0,0,0,0,0,0,0,0,1],[0,1,0]);
                w1=obj.Parent.Width1;
                w2=obj.Parent.Width2;
                w3=obj.Parent.Width3;

                row=1;

                uiControlsHt=24;
                row=row+1;
                obj.Parent.addText(obj.Layout,obj.SizeLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.SizeEdit,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.ElementSpacingLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.ElementSpacingEdit,row,2,w2,uiControlsHt)
                obj.Parent.addPopup(obj.Layout,obj.ElementSpacingUnits,row,3,w3,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.LatticeLabel,row,1,w1,uiControlsHt)
                obj.Parent.addPopup(obj.Layout,obj.LatticePopup,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.ArrayNormalLabel,row,1,w1,uiControlsHt)
                obj.Parent.addPopup(obj.Layout,obj.ArrayNormalPopup,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.TaperTypeLabel,row,1,w1,uiControlsHt)
                obj.Parent.addPopup(obj.Layout,obj.TaperTypePopup,row,2,w2,uiControlsHt)

                switch obj.TaperTypePopup.String{obj.TaperTypePopup.Value}
                case getString(message('phased:apps:arrayapp:RowColumnTaper'))
                    addRowColumnTaperUI(obj,row,w1,w2,uiControlsHt);
                case getString(message('phased:apps:arrayapp:Custom'))
                    row=row+1;
                    obj.Parent.addText(obj.Layout,obj.CustomTaperLabel,row,1,w1,uiControlsHt)
                    obj.Parent.addEdit(obj.Layout,obj.CustomTaperEdit,row,2,w2,uiControlsHt)

                    obj.RowTaperLabel.Visible='off';
                    obj.RowTaperPopup.Visible='off';
                    obj.RowSideLobeAttenuationLabel.Visible='off';
                    obj.RowSideLobeAttenuationEdit.Visible='off';
                    obj.RowBetaLabel.Visible='off';
                    obj.RowBetaEdit.Visible='off';
                    obj.RowNbarLabel.Visible='off';
                    obj.RowNbarEdit.Visible='off';
                    obj.CustomRowTaperLabel.Visible='off';
                    obj.CustomRowTaperEdit.Visible='off';

                    obj.ColumnTaperLabel.Visible='off';
                    obj.ColumnTaperPopup.Visible='off';
                    obj.ColumnSideLobeAttenuationLabel.Visible='off';
                    obj.ColumnSideLobeAttenuationEdit.Visible='off';
                    obj.ColumnBetaLabel.Visible='off';
                    obj.ColumnBetaEdit.Visible='off';
                    obj.ColumnNbarLabel.Visible='off';
                    obj.ColumnNbarEdit.Visible='off';
                    obj.CustomColumnTaperLabel.Visible='off';
                    obj.CustomColumnTaperEdit.Visible='off';

                    obj.CustomTaperLabel.Visible='on';
                    obj.CustomTaperEdit.Visible='on';
                end


                [~,~,w,h]=getMinimumSize(obj.Layout);
                obj.Width=sum(w)+obj.Layout.HorizontalGap*(numel(w)+1);
                obj.Height=max(h(2:end))*numel(h(2:end))+...
                obj.Layout.VerticalGap*(numel(h(2:end))+6);
            else
                obj.SizeLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',1,'Column',1);
                obj.SizeEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',1,'Column',2);
                obj.ElementSpacingLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',2,'Column',1);
                obj.ElementSpacingEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',2,'Column',2);
                obj.ElementSpacingUnits.Layout=matlab.ui.layout.GridLayoutOptions('Row',2,'Column',3);
                obj.LatticeLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',3,'Column',1);
                obj.LatticePopup.Layout=matlab.ui.layout.GridLayoutOptions('Row',3,'Column',2);
                obj.ArrayNormalLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',4,'Column',1);
                obj.ArrayNormalPopup.Layout=matlab.ui.layout.GridLayoutOptions('Row',4,'Column',2);
                obj.TaperTypeLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',5,'Column',1);
                obj.TaperTypePopup.Layout=matlab.ui.layout.GridLayoutOptions('Row',5,'Column',2);

                obj.RowTaperLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',6,'Column',1);
                obj.RowTaperPopup.Layout=matlab.ui.layout.GridLayoutOptions('Row',6,'Column',2);
                obj.RowSideLobeAttenuationLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',7,'Column',1);
                obj.RowSideLobeAttenuationEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',7,'Column',2);
                obj.RowNbarLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',8,'Column',1);
                obj.RowNbarEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',8,'Column',2);
                obj.RowBetaLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',9,'Column',1);
                obj.RowBetaEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',9,'Column',2);
                obj.CustomRowTaperLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',10,'Column',1);
                obj.CustomRowTaperEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',10,'Column',2);

                obj.ColumnTaperLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',11,'Column',1);
                obj.ColumnTaperPopup.Layout=matlab.ui.layout.GridLayoutOptions('Row',11,'Column',2);
                obj.ColumnSideLobeAttenuationLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',12,'Column',1);
                obj.ColumnSideLobeAttenuationEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',12,'Column',2);
                obj.ColumnNbarLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',13,'Column',1);
                obj.ColumnNbarEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',13,'Column',2);
                obj.ColumnBetaLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',14,'Column',1);
                obj.ColumnBetaEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',14,'Column',2);
                obj.CustomColumnTaperLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',15,'Column',1);
                obj.CustomColumnTaperEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',15,'Column',2);

                obj.CustomTaperLabel.Layout=matlab.ui.layout.GridLayoutOptions('Row',16,'Column',1);
                obj.CustomTaperEdit.Layout=matlab.ui.layout.GridLayoutOptions('Row',16,'Column',2);

                obj.RowTaperLabel.Visible='off';
                obj.RowTaperPopup.Visible='off';
                obj.RowSideLobeAttenuationLabel.Visible='off';
                obj.RowSideLobeAttenuationEdit.Visible='off';
                obj.RowBetaLabel.Visible='off';
                obj.RowBetaEdit.Visible='off';
                obj.RowNbarLabel.Visible='off';
                obj.RowNbarEdit.Visible='off';
                obj.CustomRowTaperLabel.Visible='off';
                obj.CustomRowTaperEdit.Visible='off';

                obj.ColumnTaperLabel.Visible='off';
                obj.ColumnTaperPopup.Visible='off';
                obj.ColumnSideLobeAttenuationLabel.Visible='off';
                obj.ColumnSideLobeAttenuationEdit.Visible='off';
                obj.ColumnBetaLabel.Visible='off';
                obj.ColumnBetaEdit.Visible='off';
                obj.ColumnNbarLabel.Visible='off';
                obj.ColumnNbarEdit.Visible='off';
                obj.CustomColumnTaperLabel.Visible='off';
                obj.CustomColumnTaperEdit.Visible='off';

                obj.CustomTaperLabel.Visible='off';
                obj.CustomTaperEdit.Visible='off';

                obj.Layout.RowHeight={'fit','fit','fit','fit','fit','fit','fit','fit',...
                'fit','fit','fit','fit','fit','fit','fit','fit'};
                switch obj.TaperTypePopup.Value
                case getString(message('phased:apps:arrayapp:RowColumnTaper'))
                    obj.RowTaperLabel.Visible='on';
                    obj.RowTaperPopup.Visible='on';
                    obj.ColumnTaperLabel.Visible='on';
                    obj.ColumnTaperPopup.Visible='on';
                    switch obj.RowTaperPopup.Value
                    case getString(message('phased:apps:arrayapp:None'))

                        obj.Layout.RowHeight([7:10,16])={0,0,0,0,0};
                    case getString(message('phased:apps:arrayapp:Hamming'))

                        obj.Layout.RowHeight([7:10,16])={0,0,0,0,0};
                    case getString(message('phased:apps:arrayapp:Chebyshev'))

                        obj.RowSideLobeAttenuationLabel.Visible='on';
                        obj.RowSideLobeAttenuationEdit.Visible='on';
                        obj.Layout.RowHeight([8:10,16])={0,0,0,0};
                    case getString(message('phased:apps:arrayapp:Hann'))

                        obj.Layout.RowHeight([7:10,16])={0,0,0,0,0};
                    case getString(message('phased:apps:arrayapp:Kaiser'))

                        obj.RowBetaLabel.Visible='on';
                        obj.RowBetaEdit.Visible='on';
                        obj.Layout.RowHeight([7:8,10,16])={0,0,0,0};
                    case getString(message('phased:apps:arrayapp:Taylor'))

                        obj.RowSideLobeAttenuationLabel.Visible='on';
                        obj.RowSideLobeAttenuationEdit.Visible='on';
                        obj.RowNbarLabel.Visible='on';
                        obj.RowNbarEdit.Visible='on';
                        obj.Layout.RowHeight([9:10,16])={0,0,0};
                    case getString(message('phased:apps:arrayapp:Custom'))

                        obj.CustomRowTaperLabel.Visible='on';
                        obj.CustomRowTaperEdit.Visible='on';
                        obj.Layout.RowHeight([7:9,16])={0,0,0,0};
                    end

                    switch obj.ColumnTaperPopup.Value
                    case getString(message('phased:apps:arrayapp:None'))

                        obj.Layout.RowHeight(12:16)={0,0,0,0,0};
                    case getString(message('phased:apps:arrayapp:Hamming'))

                        obj.Layout.RowHeight(12:16)={0,0,0,0,0};
                    case getString(message('phased:apps:arrayapp:Chebyshev'))

                        obj.ColumnSideLobeAttenuationLabel.Visible='on';
                        obj.ColumnSideLobeAttenuationEdit.Visible='on';
                        obj.Layout.RowHeight(13:16)={0,0,0,0};
                    case getString(message('phased:apps:arrayapp:Hann'))

                        obj.Layout.RowHeight(12:16)={0,0,0,0,0};
                    case getString(message('phased:apps:arrayapp:Kaiser'))

                        obj.ColumnBetaLabel.Visible='on';
                        obj.ColumnBetaEdit.Visible='on';
                        obj.Layout.RowHeight([12:13,15:16])={0,0,0,0};
                    case getString(message('phased:apps:arrayapp:Taylor'))

                        obj.ColumnSideLobeAttenuationLabel.Visible='on';
                        obj.ColumnSideLobeAttenuationEdit.Visible='on';
                        obj.ColumnNbarLabel.Visible='on';
                        obj.ColumnNbarEdit.Visible='on';
                        obj.Layout.RowHeight(14:16)={0,0,0};
                    case getString(message('phased:apps:arrayapp:Custom'))

                        obj.CustomColumnTaperLabel.Visible='on';
                        obj.CustomColumnTaperEdit.Visible='on';
                        obj.Layout.RowHeight([12:14,16])={0,0,0,0};
                    end

                case getString(message('phased:apps:arrayapp:Custom'))
                    obj.CustomTaperLabel.Visible='on';
                    obj.CustomTaperEdit.Visible='on';
                    obj.Layout.RowHeight(6:15)={0,0,0,0,0,0,0,0,0,0};
                end
            end
        end

        function addRowColumnTaperUI(obj,row,w1,w2,uiControlsHt)

            obj.RowTaperLabel.Visible='on';
            obj.RowTaperPopup.Visible='on';
            obj.ColumnTaperLabel.Visible='on';
            obj.ColumnTaperPopup.Visible='on';
            obj.CustomTaperLabel.Visible='off';
            obj.CustomTaperEdit.Visible='off';

            row=row+1;
            obj.Parent.addText(obj.Layout,obj.RowTaperLabel,row,1,w1,uiControlsHt)
            obj.Parent.addPopup(obj.Layout,obj.RowTaperPopup,row,2,w2,uiControlsHt)

            switch obj.RowTaperPopup.String{obj.RowTaperPopup.Value}
            case getString(message('phased:apps:arrayapp:None'))
                obj.RowSideLobeAttenuationLabel.Visible='off';
                obj.RowSideLobeAttenuationEdit.Visible='off';
                obj.RowBetaLabel.Visible='off';
                obj.RowBetaEdit.Visible='off';
                obj.RowNbarLabel.Visible='off';
                obj.RowNbarEdit.Visible='off';
                obj.CustomRowTaperLabel.Visible='off';
                obj.CustomRowTaperEdit.Visible='off';

            case getString(message('phased:apps:arrayapp:Hamming'))
                obj.RowSideLobeAttenuationLabel.Visible='off';
                obj.RowSideLobeAttenuationEdit.Visible='off';
                obj.RowBetaLabel.Visible='off';
                obj.RowBetaEdit.Visible='off';
                obj.RowNbarLabel.Visible='off';
                obj.RowNbarEdit.Visible='off';
                obj.CustomRowTaperLabel.Visible='off';
                obj.CustomRowTaperEdit.Visible='off';

            case getString(message('phased:apps:arrayapp:Chebyshev'))
                row=row+1;
                obj.Parent.addText(obj.Layout,obj.RowSideLobeAttenuationLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.RowSideLobeAttenuationEdit,row,2,w2,uiControlsHt)

                obj.RowSideLobeAttenuationLabel.Visible='on';
                obj.RowSideLobeAttenuationEdit.Visible='on';
                obj.RowBetaLabel.Visible='off';
                obj.RowBetaEdit.Visible='off';
                obj.RowNbarLabel.Visible='off';
                obj.RowNbarEdit.Visible='off';
                obj.CustomRowTaperLabel.Visible='off';
                obj.CustomRowTaperEdit.Visible='off';

            case getString(message('phased:apps:arrayapp:Hann'))
                obj.RowSideLobeAttenuationLabel.Visible='off';
                obj.RowSideLobeAttenuationEdit.Visible='off';
                obj.RowBetaLabel.Visible='off';
                obj.RowBetaEdit.Visible='off';
                obj.RowNbarLabel.Visible='off';
                obj.RowNbarEdit.Visible='off';
                obj.CustomRowTaperLabel.Visible='off';
                obj.CustomRowTaperEdit.Visible='off';

            case getString(message('phased:apps:arrayapp:Kaiser'))
                row=row+1;
                obj.Parent.addText(obj.Layout,obj.RowBetaLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.RowBetaEdit,row,2,w2,uiControlsHt)

                obj.RowSideLobeAttenuationLabel.Visible='off';
                obj.RowSideLobeAttenuationEdit.Visible='off';
                obj.RowBetaLabel.Visible='on';
                obj.RowBetaEdit.Visible='on';
                obj.RowNbarLabel.Visible='off';
                obj.RowNbarEdit.Visible='off';
                obj.CustomRowTaperLabel.Visible='off';
                obj.CustomRowTaperEdit.Visible='off';

            case getString(message('phased:apps:arrayapp:Taylor'))
                row=row+1;
                obj.Parent.addText(obj.Layout,obj.RowSideLobeAttenuationLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.RowSideLobeAttenuationEdit,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.RowNbarLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.RowNbarEdit,row,2,w2,uiControlsHt)

                obj.RowSideLobeAttenuationLabel.Visible='on';
                obj.RowSideLobeAttenuationEdit.Visible='on';
                obj.RowBetaLabel.Visible='off';
                obj.RowBetaEdit.Visible='off';
                obj.RowNbarLabel.Visible='on';
                obj.RowNbarEdit.Visible='on';
                obj.CustomRowTaperLabel.Visible='off';
                obj.CustomRowTaperEdit.Visible='off';
            case getString(message('phased:apps:arrayapp:Custom'))

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.CustomRowTaperLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.CustomRowTaperEdit,row,2,w2,uiControlsHt)

                obj.RowSideLobeAttenuationLabel.Visible='off';
                obj.RowSideLobeAttenuationEdit.Visible='off';
                obj.RowBetaLabel.Visible='off';
                obj.RowBetaEdit.Visible='off';
                obj.RowNbarLabel.Visible='off';
                obj.RowNbarEdit.Visible='off';
                obj.CustomRowTaperLabel.Visible='on';
                obj.CustomRowTaperEdit.Visible='on';
            end

            row=row+1;
            obj.Parent.addText(obj.Layout,obj.ColumnTaperLabel,row,1,w1,uiControlsHt)
            obj.Parent.addPopup(obj.Layout,obj.ColumnTaperPopup,row,2,w2,uiControlsHt)

            switch obj.ColumnTaperPopup.String{obj.ColumnTaperPopup.Value}
            case getString(message('phased:apps:arrayapp:None'))
                obj.ColumnSideLobeAttenuationLabel.Visible='off';
                obj.ColumnSideLobeAttenuationEdit.Visible='off';
                obj.ColumnBetaLabel.Visible='off';
                obj.ColumnBetaEdit.Visible='off';
                obj.ColumnNbarLabel.Visible='off';
                obj.ColumnNbarEdit.Visible='off';
                obj.CustomColumnTaperLabel.Visible='off';
                obj.CustomColumnTaperEdit.Visible='off';
            case getString(message('phased:apps:arrayapp:Hamming'))
                obj.ColumnSideLobeAttenuationLabel.Visible='off';
                obj.ColumnSideLobeAttenuationEdit.Visible='off';
                obj.ColumnBetaLabel.Visible='off';
                obj.ColumnBetaEdit.Visible='off';
                obj.ColumnNbarLabel.Visible='off';
                obj.ColumnNbarEdit.Visible='off';
                obj.CustomColumnTaperLabel.Visible='off';
                obj.CustomColumnTaperEdit.Visible='off';
            case getString(message('phased:apps:arrayapp:Chebyshev'))
                row=row+1;
                obj.Parent.addText(obj.Layout,obj.ColumnSideLobeAttenuationLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.ColumnSideLobeAttenuationEdit,row,2,w2,uiControlsHt)

                obj.ColumnSideLobeAttenuationLabel.Visible='on';
                obj.ColumnSideLobeAttenuationEdit.Visible='on';
                obj.ColumnBetaLabel.Visible='off';
                obj.ColumnBetaEdit.Visible='off';
                obj.ColumnNbarLabel.Visible='off';
                obj.ColumnNbarEdit.Visible='off';
                obj.CustomColumnTaperLabel.Visible='off';
                obj.CustomColumnTaperEdit.Visible='off';

            case getString(message('phased:apps:arrayapp:Hann'))
                obj.ColumnSideLobeAttenuationLabel.Visible='off';
                obj.ColumnSideLobeAttenuationEdit.Visible='off';
                obj.ColumnBetaLabel.Visible='off';
                obj.ColumnBetaEdit.Visible='off';
                obj.ColumnNbarLabel.Visible='off';
                obj.ColumnNbarEdit.Visible='off';
                obj.CustomColumnTaperLabel.Visible='off';
                obj.CustomColumnTaperEdit.Visible='off';
            case getString(message('phased:apps:arrayapp:Kaiser'))
                row=row+1;
                obj.Parent.addText(obj.Layout,obj.ColumnBetaLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.ColumnBetaEdit,row,2,w2,uiControlsHt)

                obj.ColumnSideLobeAttenuationLabel.Visible='off';
                obj.ColumnSideLobeAttenuationEdit.Visible='off';
                obj.ColumnBetaLabel.Visible='on';
                obj.ColumnBetaEdit.Visible='on';
                obj.ColumnNbarLabel.Visible='off';
                obj.ColumnNbarEdit.Visible='off';
                obj.CustomColumnTaperLabel.Visible='off';
                obj.CustomColumnTaperEdit.Visible='off';

            case getString(message('phased:apps:arrayapp:Taylor'))
                row=row+1;
                obj.Parent.addText(obj.Layout,obj.ColumnSideLobeAttenuationLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.ColumnSideLobeAttenuationEdit,row,2,w2,uiControlsHt)

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.ColumnNbarLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.ColumnNbarEdit,row,2,w2,uiControlsHt)

                obj.ColumnSideLobeAttenuationLabel.Visible='on';
                obj.ColumnSideLobeAttenuationEdit.Visible='on';
                obj.ColumnBetaLabel.Visible='off';
                obj.ColumnBetaEdit.Visible='off';
                obj.ColumnNbarLabel.Visible='on';
                obj.ColumnNbarEdit.Visible='on';
                obj.CustomColumnTaperLabel.Visible='off';
                obj.CustomColumnTaperEdit.Visible='off';

            case getString(message('phased:apps:arrayapp:Custom'))

                row=row+1;
                obj.Parent.addText(obj.Layout,obj.CustomColumnTaperLabel,row,1,w1,uiControlsHt)
                obj.Parent.addEdit(obj.Layout,obj.CustomColumnTaperEdit,row,2,w2,uiControlsHt)

                obj.ColumnSideLobeAttenuationLabel.Visible='off';
                obj.ColumnSideLobeAttenuationEdit.Visible='off';
                obj.ColumnBetaLabel.Visible='off';
                obj.ColumnBetaEdit.Visible='off';
                obj.ColumnNbarLabel.Visible='off';
                obj.ColumnNbarEdit.Visible='off';
                obj.CustomColumnTaperLabel.Visible='on';
                obj.CustomColumnTaperEdit.Visible='on';
            end
        end
        function parameterChanged(obj,e)




            prop=e.Source.Tag;
            switch prop
            case 'sizeEdit'
                try
                    sigdatatypes.validateIndex(obj.Size,...
                    '','Size',{'size',[1,2],'>=',2});
                    obj.ValidSize=obj.Size;
                catch me
                    obj.Size=obj.ValidSize;
                    throwError(obj.Parent.App,me);
                    return;
                end

            case 'elementSpacingEdit'
                try
                    sigdatatypes.validateDistance(...
                    obj.ElementSpacing,'','Element Spacing',...
                    {'size',[1,2],'positive','finite'});
                    obj.ValidElementSpacing=obj.ElementSpacing;
                catch me
                    obj.ElementSpacing=obj.ValidElementSpacing;
                    throwError(obj.Parent.App,me);
                    return;
                end
            case 'taperEdit'
                try
                    validateattributes(obj.CustomTaper,{'double'},...
                    {'nonnan','nonempty','finite','2d'},...
                    '','Taper');
                    obj.ValidCustomTaper=obj.CustomTaper;
                catch me
                    obj.CustomTaper=obj.ValidCustomTaper;
                    throwError(obj.Parent.App,me);
                    return;
                end
            case 'rowCustomTaperEdit'
                try
                    validateattributes(obj.RowCustomTaper,{'double'},...
                    {'nonnan','nonempty','finite','vector'},...
                    '','Taper');
                    obj.ValidRowCustomTaper=obj.RowCustomTaper;
                catch me
                    obj.RowCustomTaper=obj.ValidRowCustomTaper;
                    throwError(obj.Parent.App,me);
                    return;
                end
            case 'columnCustomTaperEdit'
                try
                    validateattributes(obj.ColumnCustomTaper,{'double'},...
                    {'nonnan','nonempty','finite','vector'},...
                    '','Taper');
                    obj.ValidColumnCustomTaper=obj.ColumnCustomTaper;
                catch me
                    obj.ColumnCustomTaper=obj.ValidColumnCustomTaper;
                    throwError(obj.Parent.App,me);
                    return;
                end
            case 'taperTypePopup'
                if~isUIFigure(obj.Parent)
                    obj.TaperInputType=obj.TaperTypePopup.String{obj.TaperTypePopup.Value};
                else
                    obj.TaperInputType=obj.TaperTypePopup.Value;
                end
                layoutPanel(obj);
            case 'rowTaperPopup'
                if~isUIFigure(obj.Parent)
                    obj.RowTaper=obj.RowTaperPopup.String{obj.RowTaperPopup.Value};
                else
                    obj.RowTaper=obj.RowTaperPopup.Value;
                end
                layoutPanel(obj);
            case 'columnTaperPopup'
                if~isUIFigure(obj.Parent)
                    obj.ColumnTaper=obj.ColumnTaperPopup.String{obj.ColumnTaperPopup.Value};
                else
                    obj.ColumnTaper=obj.ColumnTaperPopup.Value;
                end
                layoutPanel(obj);
            case 'row_sideLobeEdit'
                try
                    validateattributes(obj.RowSideLobeAttenuation,...
                    {'double'},{'positive','scalar','finite',...
                    'nonnan','nonempty','real'},'',...
                    'Sidelobe Attenuation');
                    obj.ValidRowSideLobeAttenuation=obj.RowSideLobeAttenuation;
                catch me
                    obj.RowSideLobeAttenuation=obj.ValidRowSideLobeAttenuation;
                    throwError(obj.Parent.App,me);
                    return;
                end
            case 'row_betaEdit'
                try
                    validateattributes(obj.RowBeta,{'double'},...
                    {'scalar','finite','nonnan','nonempty',...
                    'real'},'','Beta');
                    obj.ValidRowBeta=obj.RowBeta;
                catch me
                    obj.RowBeta=obj.ValidRowBeta;
                    throwError(obj.Parent.App,me);
                    return;
                end
            case 'row_nBarEdit'
                try
                    validateattributes(obj.RowNbar,{'double'},...
                    {'positive','scalar','integer','finite',...
                    'nonnan','nonempty','real'},'','Nbar');
                    obj.ValidRowNbar=obj.RowNbar;
                catch me
                    obj.RowNbar=obj.ValidRowNbar;
                    throwError(obj.Parent.App,me);
                    return;
                end
            case 'column_sideLobeEdit'
                try
                    validateattributes(obj.ColumnSideLobeAttenuation,...
                    {'double'},{'positive','scalar','finite',...
                    'nonnan','nonempty','real'},'',...
                    'Sidelobe Attenuation');
                    obj.ValidColumnSideLobeAttenuation=obj.ColumnSideLobeAttenuation;
                catch me
                    obj.ColumnSideLobeAttenuation=obj.ValidColumnSideLobeAttenuation;
                    throwError(obj.Parent.App,me);
                    return;
                end
            case 'column_betaEdit'
                try
                    validateattributes(obj.ColumnBeta,{'double'},...
                    {'scalar','finite','nonnan','nonempty',...
                    'real'},'','Beta');
                    obj.ValidColumnBeta=obj.ColumnBeta;
                catch me
                    obj.ColumnBeta=obj.ValidColumnBeta;
                    throwError(obj.Parent.App,me);
                    return;
                end
            case 'column_nBarEdit'
                try
                    validateattributes(obj.ColumnNbar,{'double'},...
                    {'positive','scalar','integer','finite',...
                    'nonnan','nonempty','real'},'','Nbar');
                    obj.ValidColumnNbar=obj.ColumnNbar;
                catch me
                    obj.ColumnNbar=obj.ValidColumnNbar;
                    throwError(obj.Parent.App,me);
                    return;
                end
            end


            enableAnalyzeButton(obj.Parent.App);
        end
        function layoutPanel(obj)
            layoutUIControls(obj)
            if~isUIFigure(obj.Parent)
                remove(obj.Parent.Layout,1,1)
                add(obj.Parent.Layout,obj.Parent.ArrayDialog.Panel,1,1,...
                'MinimumWidth',obj.Width,...
                'Fill','Horizontal',...
                'MinimumHeight',obj.Height,...
                'Anchor','North')

                update(obj.Parent.Layout,'force');
            else
                adjustLayout(obj.Parent.App);
            end
        end
    end
end
