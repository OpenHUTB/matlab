


classdef ArrayGraph2D<phased.apps.internal.SensorArrayViewer.ArrayGraph

    properties
AD2DOption
    end

    methods

        function obj=ArrayGraph2D(App,panel,op)
            obj=obj@phased.apps.internal.SensorArrayViewer.ArrayGraph(App,panel,['2D_',op.Tag]);

            obj.AD2DOption=op;

            obj.CanRotate=false;
            fmt=op.Format;
            if strcmp(fmt,'Line')
                obj.CanPan=true;
            else
                obj.CanPan=false;
            end
        end

        function draw(obj)

            curAT=obj.Application.Settings.getCurArrayType();
            fmt=obj.AD2DOption.Format;
            respCut=obj.AD2DOption.ResponseCut;
            h=curAT.ArrayObj;
            F=curAT.SignalFreqs;
            SA=curAT.SteeringAngles;
            PS=curAT.PropSpeed;
            PSB=curAT.PhaseShiftBits;

            if strcmp(fmt,'Line')
                fmt='rectangular';
            else
                fmt='polar';
            end

            if obj.AD2DOption==phased.apps.internal.SensorArrayViewer.ArrayDir2dOps.ElevationCutLine||...
                obj.AD2DOption==phased.apps.internal.SensorArrayViewer.ArrayDir2dOps.ElevationCutPolar
                cutAngle=obj.Application.Visualization.ElCutValue;
            else
                cutAngle=obj.Application.Visualization.AzCutValue;
            end

            axes(obj.hAxes);
            tag=obj.hAxes.Tag;

            isSteered=curAT.SteeringIsOn;
            if isSteered
                w=curAT.SteerWeights;

                NumF=length(F);
                NumSA=size(SA,2);
                NumPSB=length(PSB);
                NumPlots=size(w,2);

                NumNonRefPlots=max([NumF,NumSA,NumPSB]);
                NumRefPlots=NumPlots-NumNonRefPlots;

                if(NumRefPlots>0)&&(NumF>1)
                    if NumPSB>1
                        F_tmp=zeros(1,NumPlots);
                        plotIdx=1;
                        for idx=1:NumF
                            F_tmp(plotIdx)=F(idx);
                            if PSB(idx)>0
                                F_tmp(plotIdx+1)=F(idx);
                                plotIdx=plotIdx+1;
                            end
                            plotIdx=plotIdx+1;
                        end
                        F=F_tmp;
                    else
                        F_tmp=[F;F];
                        F=F_tmp(:).';
                    end
                end

                if obj.AD2DOption~=phased.apps.internal.SensorArrayViewer.ArrayDir2dOps.UCut
                    if strcmpi(respCut,'Az')
                        pattern(h,F,-180:180,cutAngle,'CoordinateSystem',fmt,...
                        'Type','directivity','PropagationSpeed',PS,'Weights',w);

                    else
                        pattern(h,F,cutAngle,-90:90,'CoordinateSystem',fmt,...
                        'Type','directivity','PropagationSpeed',PS,'Weights',w);
                    end
                else
                    pattern(h,F,-1:0.01:1,0,'CoordinateSystem','UV',...
                    'Type','directivity','PropagationSpeed',PS,'weights',w);
                end
            else
                if obj.AD2DOption~=phased.apps.internal.SensorArrayViewer.ArrayDir2dOps.UCut
                    if strcmpi(respCut,'Az')
                        pattern(h,F,-180:180,cutAngle,'CoordinateSystem',fmt,...
                        'Type','directivity','PropagationSpeed',PS);
                    else
                        pattern(h,F,cutAngle,-90:90,'CoordinateSystem',fmt,...
                        'Type','directivity','PropagationSpeed',PS);
                    end
                else
                    pattern(h,F,-1:0.01:1,0,'CoordinateSystem','UV',...
                    'Type','directivity','PropagationSpeed',PS);
                end
            end
            set(obj.hAxes,'Tag',tag);
        end

        function update(obj)
            fmt=obj.AD2DOption.Format;
            if~strcmp(fmt,'Polar')
                if obj.NeedsRedraw
                    obj.updateLegend();
                end
                axis(obj.hAxes,'square');
            end
        end

        function updateLegend(obj)

            curAT=obj.Application.Settings.getCurArrayType();
            w=curAT.SteerWeights;

            F=curAT.SignalFreqs;
            SA=curAT.SteeringAngles;
            PSB=curAT.PhaseShiftBits;




            NumSA=size(SA,2);
            NumF=length(F);
            NumPSB=length(PSB);
            NumPlots=size(w,2);


            [SA,F,PSB]=phased.apps.internal.SensorArrayViewer.makeEqualLength(SA,F,PSB,NumSA,NumF,NumPSB);


            [NumRefPlots,RefPlotAtEndFlag]=computeNumReferencePlots(PSB,NumSA,NumF,NumPSB);


            legend_string=cell(1,NumPlots);

            legend_idx=1;
            for idx=1:length(F)
                [Fval,~,Fletter]=engunits(F(idx));
                if curAT.SteeringIsOn
                    if size(SA,2)==1
                        az_str=num2str(SA(1,1));
                        elev_str=num2str(SA(2,1));
                    else
                        az_str=num2str(SA(1,idx));
                        elev_str=num2str(SA(2,idx));
                    end
                    if PSB(idx)>0
                        legend_string{legend_idx}=[num2str(Fval),Fletter,getString(message('phased:apps:arrayapp:Hz')),';'...
                        ,getString(message('phased:apps:arrayapp:azel',az_str,elev_str)),'; ',num2str(PSB(idx)),'-bit Quantized'];

                        if(NumRefPlots>0)&&((~RefPlotAtEndFlag)||(RefPlotAtEndFlag&&(idx==length(F))))
                            legend_string{legend_idx+1}=[num2str(Fval),Fletter,getString(message('phased:apps:arrayapp:Hz')),';'...
                            ,getString(message('phased:apps:arrayapp:azel',az_str,elev_str)),'; ','Reference'];

                            CurrentTag=['Weights',' ',num2str(legend_idx)];
                            RefTag=['Weights',' ',num2str(legend_idx+1)];

                            CurrentLine=findobj(gca,'Tag',CurrentTag);
                            RefLine=findobj(gca,'Tag',RefTag);

                            set(RefLine,'Color',CurrentLine.Color,'LineStyle','-.');

                            legend_idx=legend_idx+1;
                        end
                    else
                        legend_string{legend_idx}=[num2str(Fval),Fletter,getString(message('phased:apps:arrayapp:Hz')),';'...
                        ,getString(message('phased:apps:arrayapp:azel',az_str,elev_str))];
                    end
                else
                    legend_string{idx}=[num2str(Fval),Fletter,getString(message('phased:apps:arrayapp:Hz')),';'...
                    ,getString(message('phased:apps:arrayapp:NoSteering'))];
                end

                legend_idx=legend_idx+1;

            end

            legend(legend_string,'Location','southeast','Tag',['legend_2D_',obj.AD2DOption.Tag],'AutoUpdate','off');
        end


        function genCode(obj,mcode)

            curAT=obj.Application.Settings.getCurArrayType();
            isSteered=curAT.SteeringIsOn;
            weight_str='';
            if isSteered
                mcode.addcr('NumCurves = length(F);');

                mcode.addcr('%Calculate Steering Weights');
                mcode.addcr('w = zeros(getDOF(h), NumCurves);');
                mcode.addcr('for idx = 1:length(F)');
                mcode.addcr('    SV = phased.SteeringVector(''SensorArray'',h, ''PropagationSpeed'', PS, ''NumPhaseShifterBits'', PSB(idx));');
                mcode.addcr('    w(:, idx) = step(SV, F(idx), SA(:, idx));');
                mcode.addcr('end');
                weight_str=',''weights'', w';
            else
                mcode.addcr('NumCurves = length(F);');
            end

            mcode.addcr('%Plot 2d graph');
            if strcmpi(obj.AD2DOption.Format,'polar')
                fmt='polar';
            elseif strcmpi(obj.AD2DOption.Format,'uv')
                fmt='uv';
            else
                fmt='rectangular';
            end
            mcode.addcr(['fmt = ''',fmt,''';']);

            if obj.AD2DOption~=phased.apps.internal.SensorArrayViewer.ArrayDir2dOps.UCut
                if obj.AD2DOption==phased.apps.internal.SensorArrayViewer.ArrayDir2dOps.ElevationCutLine||...
                    obj.AD2DOption==phased.apps.internal.SensorArrayViewer.ArrayDir2dOps.ElevationCutPolar
                    cutAngle=obj.Application.Visualization.ElCutValue;
                    mcode.addcr(['cutAngle = ',num2str(cutAngle),';']);
                    mcode.addcr(['pattern(h, F, cutAngle, -90:90, ''PropagationSpeed'', PS, ''Type'', ''directivity'', ',...
                    '''CoordinateSystem'', fmt ',weight_str,');']);
                else
                    cutAngle=obj.Application.Visualization.AzCutValue;
                    mcode.addcr(['cutAngle = ',num2str(cutAngle),';']);
                    mcode.addcr(['pattern(h, F, -180:180, cutAngle, ''PropagationSpeed'', PS, ''Type'', ''directivity'', ',...
                    '''CoordinateSystem'', fmt ',weight_str,');']);
                end
            else
                mcode.addcr(['pattern(h, F, -1:0.01:1, 0, ''PropagationSpeed'', PS, ''Type'',''directivity'',''CoordinateSystem'', fmt',weight_str,');']);
            end

            if~strcmp(obj.AD2DOption.Format,'Polar')
                mcode.addcr('axis(hAxes,''square'')');
            end

            obj.genCodeLegend(mcode);

        end


        function genCodeLegend(obj,mcode)

            mcode.addcr('%Create legend');
            curAT=obj.Application.Settings.getCurArrayType();
            isSteered=curAT.SteeringIsOn;

            mcode.addcr('legend_string = cell(1,NumCurves);');
            mcode.addcr('lines = findobj(gca,''Type'',''line'');');
            mcode.addcr('for idx = 1:NumCurves');
            mcode.addcr('   [Fval, ~, Fletter] = engunits(F(idx));');
            if isSteered
                mcode.addcr('   if size(SA, 2) == 1');
                mcode.addcr('      az_str = num2str(SA(1,1));');
                mcode.addcr('      elev_str = num2str(SA(2,1));');
                mcode.addcr('   else');
                mcode.addcr('      az_str = num2str(SA(1, idx));');
                mcode.addcr('      elev_str = num2str(SA(2, idx));');
                mcode.addcr('   end');
                mcode.addcr('   if PSB(idx)>0');
                mcode.addcr(['        legend_string{idx} = [num2str(Fval) Fletter ''Hz;''',' num2str(SA(1,idx)) ''Az'' '' '' elev_str ''El'' '';'' num2str(PSB(idx)) ''-bit Quantized''];']);
                mcode.addcr('   else ');
                mcode.addcr(['        legend_string{idx} = [num2str(Fval) Fletter ''Hz;''',' num2str(SA(1,idx)) ''Az'' '' '' elev_str ''El''];']);
                mcode.addcr('   end ');
            else
                mcode.addcr('   legend_string{idx} = [num2str(Fval) Fletter ''Hz; No Steering''];');
            end
            mcode.addcr('end');
            mcode.addcr('legend(legend_string, ''Location'', ''southeast'');');

        end

    end

end


function[NumRefPlots,RefPlotAtEndFlag]=computeNumReferencePlots(PSB,NumSA,NumF,NumPSB)

    idx_forRefPlot=find(PSB);
    RefPlotAtEndFlag=0;
    if(NumF==1)&&(NumSA==1)
        if(length(idx_forRefPlot)==NumPSB)
            NumRefPlots=1;
            RefPlotAtEndFlag=1;
        else
            NumRefPlots=0;
        end
    else
        NumRefPlots=length(idx_forRefPlot);
    end
end


