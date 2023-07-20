


classdef ArrayGraphGratingLobe<phased.apps.internal.SensorArrayViewer.ArrayGraph

    methods

        function obj=ArrayGraphGratingLobe(App,panel,tag)
            obj=obj@phased.apps.internal.SensorArrayViewer.ArrayGraph(App,panel,tag);

            obj.CanRotate=false;
            obj.CanPan=true;
        end

        function draw(obj)

            curAT=obj.Application.Settings.getCurArrayType();

            h=curAT.ArrayObj;
            F=curAT.SignalFreqs;
            isSteered=curAT.SteeringIsOn;
            SA=0;
            if isSteered
                SA=curAT.SteeringAngles;
            end
            PS=curAT.PropSpeed;

            axes(obj.hAxes);
            tag=obj.hAxes.Tag;




            try
                plotGratingLobeDiagram(h,F(1),SA(:,1),PS);
            catch


                ratio=1;
                if curAT.ElemSpacingUnitsIndex~=1
                    ratio=curAT.PropSpeed./curAT.SignalFreqs(1);
                end
                elemSpacing=curAT.ElemSpacing*ratio;
                if isa(curAT,'phased.apps.internal.SensorArrayViewer.ATUniformHexagonal')
                    RS=elemSpacing/2*sqrt(3);
                    CS=elemSpacing;
                    lattice='Triangular';
                elseif isa(curAT,'phased.apps.internal.SensorArrayViewer.ATCircularPlanar')
                    RS=elemSpacing;
                    CS=elemSpacing;
                    lattice=curAT.LatticeNames{curAT.LatticeIndex};
                else
                    error(message('phased:apps:arrayapp:InvalidGratingL'));
                end
                phased.apps.internal.plotGratingLobeDiagramPlanar(RS,CS,lattice,F(1),SA(:,1),PS);
            end

            set(obj.hAxes,'Tag',tag);
        end

        function update(obj)
            if obj.NeedsRedraw
                obj.updateTitle();
            end
        end


        function genCode(obj,mcode)

            curAT=obj.Application.Settings.getCurArrayType();
            isSteered=curAT.SteeringIsOn;

            mcode.addcr('%Plot grating lobe diagram');

            if isa(curAT,'phased.apps.internal.SensorArrayViewer.ATUniformLinear')||...
                isa(curAT,'phased.apps.internal.SensorArrayViewer.ATUniformRectangular')
                if isSteered
                    mcode.addcr('plotGratingLobeDiagram(h,F(1),SA(:,1),PS);');
                else
                    mcode.addcr('plotGratingLobeDiagram(h,F(1),0,PS);');
                end

            else
                ratio=1;
                if curAT.ElemSpacingUnitsIndex~=1
                    ratio=curAT.PropSpeed/curAT.SignalFreqs(1);
                end
                elemSpacing=curAT.ElemSpacing*ratio;
                if isa(curAT,'phased.apps.internal.SensorArrayViewer.ATUniformHexagonal')
                    mcode.addcr(['RS = ',num2str(elemSpacing/2*sqrt(3)),';']);
                    mcode.addcr(['CS = ',num2str(elemSpacing),';']);
                    mcode.addcr('lattice = ''Triangular'';');
                elseif isa(curAT,'phased.apps.internal.SensorArrayViewer.ATCircularPlanar')
                    mcode.addcr(['RS = ',num2str(elemSpacing),';']);
                    mcode.addcr(['CS = ',num2str(elemSpacing),';']);
                    mcode.addcr(['lattice = ''',curAT.LatticeNames{curAT.LatticeIndex},''';']);
                else
                    error(message('phased:apps:arrayapp:InvalidGratingL'));
                end

                if isSteered
                    mcode.addcr('phased.apps.internal.plotGratingLobeDiagramPlanar(RS,CS,lattice,F(1),SA(:,1),PS);');
                else
                    mcode.addcr('phased.apps.internal.plotGratingLobeDiagramPlanar(RS,CS,lattice,F(1),0,PS);');
                end
            end

            obj.genCodeTitle(mcode);

        end
    end

end

