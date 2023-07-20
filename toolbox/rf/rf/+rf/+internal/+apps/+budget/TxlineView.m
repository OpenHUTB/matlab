classdef TxlineView<rf.internal.apps.budget.ElementView





    properties
Icon
        Type='microstrip';
    end

    methods

        function self=TxlineView(elem,varargin)



            self=self@rf.internal.apps.budget.ElementView(varargin{:});
            str=strsplit(class(elem),'txline');
            self.Type=str{2};
            if~strcmpi(elem.Name,'microstrip')
                if self.Canvas.View.UseAppContainer
                    self.Picture.Block.ImageSource=self.Icon;
                else
                    self.Picture.Block.CData=self.Icon;
                end
            end
        end

        function val=get.Icon(self)
            if~strcmpi(self.Type,'Stripline')
                val=imread([fullfile('+rf','+internal','+apps','+budget')...
                ,filesep,lower(self.Type),'_60.png']);
            else
                val=imread([fullfile('+rf','+internal','+apps','+budget')...
                ,filesep,(self.Type),'_60.png']);
            end
        end

        function unselectElement(self)


            dlg=self.Canvas.View.Parameters.ElementDialog;
            dlg.Parent.View.setStatusBarMsg('');
            if self.Canvas.View.UseAppContainer
                dlg.Parent.notify('DisableCanvas',...
                rf.internal.apps.budget.ElementParameterChangedEventData(1,'ApplyButton','inactive'));
            else
                dlg.Parent.notify('DisableCanvas',...
                rf.internal.apps.budget.ElementParameterChangedEventData(1,'ApplyTag','inactive'));
            end
            unselectElement@rf.internal.apps.budget.ElementView(self)
        end

        function selectElement(self,elem)


            selectElement@rf.internal.apps.budget.ElementView(self,elem)
            dlg=self.Canvas.View.Parameters.ElementDialog;

            if self.Canvas.View.UseAppContainer
                if contains(dlg.Type,{'Microstrip','Coaxial','CPW','TwoWire','ParallelPlate','Stripline'})
                    switch lower(dlg.Type)
                    case 'microstrip'
                        dlg.Name=elem.Name;
                        dlg.txWidth=elem.Width;
                        dlg.txHeight=elem.Height;
                        dlg.Thickness=elem.Thickness;
                        dlg.EpsilonR=elem.EpsilonR;
                        dlg.LossTangent=elem.LossTangent;
                        dlg.SigmaCond=elem.SigmaCond;
                        dlg.LineLength=elem.LineLength;
                    case 'coaxial'
                        dlg.Name=elem.Name;
                        dlg.OuterRadius=elem.OuterRadius;
                        dlg.InnerRadius=elem.InnerRadius;
                        dlg.MuR=elem.MuR;
                        dlg.EpsilonR=elem.EpsilonR;
                        dlg.LossTangent=elem.LossTangent;
                        dlg.SigmaCond=elem.SigmaCond;
                        dlg.LineLength=elem.LineLength;
                    case 'cpw'
                        dlg.Name=elem.Name;
                        dlg.ConductorWidth=elem.ConductorWidth;
                        dlg.SlotWidth=elem.SlotWidth;
                        dlg.txHeight=elem.Height;
                        dlg.Thickness=elem.Thickness;
                        dlg.EpsilonR=elem.EpsilonR;
                        dlg.LossTangent=elem.LossTangent;
                        dlg.SigmaCond=elem.SigmaCond;
                        dlg.LineLength=elem.LineLength;

                    case 'twowire'
                        dlg.Name=elem.Name;
                        dlg.Radius=elem.Radius;
                        dlg.Separation=elem.Separation;
                        dlg.MuR=elem.MuR;
                        dlg.EpsilonR=elem.EpsilonR;
                        dlg.LossTangent=elem.LossTangent;
                        dlg.SigmaCond=elem.SigmaCond;
                        dlg.LineLength=elem.LineLength;

                    case 'parallelplate'
                        dlg.Name=elem.Name;
                        dlg.txWidth=elem.Width;
                        dlg.Separation=elem.Separation;
                        dlg.MuR=elem.MuR;
                        dlg.EpsilonR=elem.EpsilonR;
                        dlg.LossTangent=elem.LossTangent;
                        dlg.SigmaCond=elem.SigmaCond;
                        dlg.LineLength=elem.LineLength;
                    case 'stripline'
                        dlg.Name=elem.Name;
                        dlg.txWidth=elem.Width;
                        dlg.DielectricThickness=elem.DielectricThickness;
                        dlg.Thickness=elem.Thickness;
                        dlg.EpsilonR=elem.EpsilonR;
                        dlg.LossTangent=elem.LossTangent;
                        dlg.SigmaCond=elem.SigmaConductivity;
                        dlg.LineLength=elem.LineLength;

                    end

                    if strcmpi(elem.StubMode,'NotAStub')
                        rf.internal.apps.budget.setValue(self,...
                        dlg,'StubModePopup','NotAStub');
                    elseif strcmpi(elem.StubMode,'Series')
                        rf.internal.apps.budget.setValue(self,...
                        dlg,'StubModePopup','Series');
                    elseif strcmpi(elem.StubMode,'Shunt')
                        rf.internal.apps.budget.setValue(self,...
                        dlg,'StubModePopup','Shunt');
                    end
                    if strcmpi(elem.Termination,'NotApplicable')
                        rf.internal.apps.budget.setValue(self,...
                        dlg,'TerminationPopup','NotApplicable');
                    elseif strcmpi(elem.Termination,'Open')
                        rf.internal.apps.budget.setValue(self,...
                        dlg,'TerminationPopup','Open');
                    elseif strcmpi(elem.Termination,'Short')
                        rf.internal.apps.budget.setValue(self,...
                        dlg,'TerminationPopup','Short');
                    end
                end
                if strcmpi(dlg.Type,'rlcgline')||strcmpi(dlg.Type,'equationbased')
                    strengunits={'','k','M','G','T'};
                    [~,~,u]=engunits(elem.Frequency);
                    i=strcmp(u,strengunits);
                    if any(i)
                        STRUnit=[strengunits(i),'Hz'];
                        value=join(STRUnit,'');
                        rf.internal.apps.budget.setValue(self,...
                        dlg,'FrequencyUnits',value);
                    else
                        rf.internal.apps.budget.setValue(self,dlg,'FrequencyUnits','Hz');
                    end

                    dlg.Frequency=elem.Frequency;

                    if strcmpi(elem.IntpType,'Linear')
                        rf.internal.apps.budget.setValue(self,...
                        dlg,'IntpTypePopup','Linear');
                    elseif strcmpi(elem.IntpType,'Cubic')
                        rf.internal.apps.budget.setValue(self,...
                        dlg,'IntpTypePopup','Cubic');
                    elseif strcmpi(elem.IntpType,'Spline')
                        rf.internal.apps.budget.setValue(self,...
                        dlg,'IntpTypePopup','Spline');
                    end

                    if strcmpi(elem.StubMode,'NotAStub')
                        rf.internal.apps.budget.setValue(self,...
                        dlg,'StubModePopup','NotAStub');
                    elseif strcmpi(elem.StubMode,'Series')
                        rf.internal.apps.budget.setValue(self,...
                        dlg,'StubModePopup','Series');
                    elseif strcmpi(elem.StubMode,'Shunt')
                        rf.internal.apps.budget.setValue(self,...
                        dlg,'StubModePopup','Shunt');
                    end
                    if strcmpi(elem.Termination,'NotApplicable')
                        rf.internal.apps.budget.setValue(self,...
                        dlg,'TerminationPopup','NotApplicable');
                    elseif strcmpi(elem.Termination,'Open')
                        rf.internal.apps.budget.setValue(self,...
                        dlg,'TerminationPopup','Open');
                    elseif strcmpi(elem.Termination,'Short')
                        rf.internal.apps.budget.setValue(self,...
                        dlg,'TerminationPopup','Short');
                    end
                end
                if strcmpi(dlg.Type,'rlcgline')
                    dlg.Name=elem.Name;
                    dlg.R=elem.R;
                    dlg.L=elem.L;
                    dlg.C=elem.C;
                    dlg.G=elem.G;
                    dlg.LineLength=elem.LineLength;
                end
                if strcmpi(dlg.Type,'equationbased')
                    dlg.Name=elem.Name;
                    dlg.Frequency=elem.Frequency;
                    dlg.Z0=elem.Z0;
                    dlg.LossDB=elem.LossDB;
                    dlg.PhaseVelocity=elem.PhaseVelocity;
                    dlg.LineLength=elem.LineLength;
                end

                if strcmpi(dlg.Type,'delaylossless')
                    dlg.Name=elem.Name;
                    dlg.Z0=elem.Z0;
                    dlg.TimeDelay=elem.TimeDelay;
                end
                if strcmpi(dlg.Type,'delaylossy')
                    dlg.Name=elem.Name;
                    dlg.Z0=elem.Z0;
                    dlg.LineLength=elem.LineLength;
                    dlg.TimeDelay=elem.TimeDelay;
                    dlg.Resistance=elem.Resistance;
                end
            else
                if contains(dlg.Type,{'Microstrip','Coaxial','CPW','TwoWire','ParallelPlate','Stripline'})
                    switch lower(dlg.Type)
                    case 'microstrip'
                        dlg.Name=elem.Name;
                        dlg.txWidth=elem.Width;
                        dlg.txHeight=elem.Height;
                        dlg.Thickness=elem.Thickness;
                        dlg.EpsilonR=elem.EpsilonR;
                        dlg.LossTangent=elem.LossTangent;
                        dlg.SigmaCond=elem.SigmaCond;
                        dlg.LineLength=elem.LineLength;
                        dlg.StubMode=elem.StubMode;
                        dlg.Termination=elem.Termination;
                    case 'coaxial'
                        dlg.Name=elem.Name;
                        dlg.OuterRadius=elem.OuterRadius;
                        dlg.InnerRadius=elem.InnerRadius;
                        dlg.MuR=elem.MuR;
                        dlg.EpsilonR=elem.EpsilonR;
                        dlg.LossTangent=elem.LossTangent;
                        dlg.SigmaCond=elem.SigmaCond;
                        dlg.LineLength=elem.LineLength;
                        dlg.StubMode=elem.StubMode;
                        dlg.Termination=elem.Termination;
                    case 'cpw'
                        dlg.Name=elem.Name;
                        dlg.ConductorWidth=elem.ConductorWidth;
                        dlg.SlotWidth=elem.SlotWidth;
                        dlg.txHeight=elem.Height;
                        dlg.Thickness=elem.Thickness;
                        dlg.EpsilonR=elem.EpsilonR;
                        dlg.LossTangent=elem.LossTangent;
                        dlg.SigmaCond=elem.SigmaCond;
                        dlg.LineLength=elem.LineLength;
                        dlg.StubMode=elem.StubMode;
                        dlg.Termination=elem.Termination;
                    case 'twowire'
                        dlg.Name=elem.Name;
                        dlg.Radius=elem.Radius;
                        dlg.Separation=elem.Separation;
                        dlg.MuR=elem.MuR;
                        dlg.EpsilonR=elem.EpsilonR;
                        dlg.LossTangent=elem.LossTangent;
                        dlg.SigmaCond=elem.SigmaCond;
                        dlg.LineLength=elem.LineLength;
                        dlg.StubMode=elem.StubMode;
                        dlg.Termination=elem.Termination;
                    case 'parallelplate'
                        dlg.Name=elem.Name;
                        dlg.txWidth=elem.Width;
                        dlg.Separation=elem.Separation;
                        dlg.MuR=elem.MuR;
                        dlg.EpsilonR=elem.EpsilonR;
                        dlg.LossTangent=elem.LossTangent;
                        dlg.SigmaCond=elem.SigmaCond;
                        dlg.LineLength=elem.LineLength;
                        dlg.StubMode=elem.StubMode;
                        dlg.Termination=elem.Termination;
                    case 'stripline'
                        dlg.Name=elem.Name;
                        dlg.txWidth=elem.Width;
                        dlg.DielectricThickness=elem.DielectricThickness;
                        dlg.Thickness=elem.Thickness;
                        dlg.EpsilonR=elem.EpsilonR;
                        dlg.LossTangent=elem.LossTangent;
                        dlg.SigmaCond=elem.SigmaConductivity;
                        dlg.LineLength=elem.LineLength;
                        dlg.StubMode=elem.StubMode;
                        dlg.Termination=elem.Termination;
                    end
                end
                if strcmpi(dlg.Type,'rlcgline')
                    dlg.Name=elem.Name;
                    dlg.Frequency=elem.Frequency;
                    dlg.R=elem.R;
                    dlg.L=elem.L;
                    dlg.C=elem.C;
                    dlg.G=elem.G;
                    dlg.IntpType=elem.IntpType;
                    dlg.LineLength=elem.LineLength;
                    dlg.StubMode=elem.StubMode;
                    dlg.Termination=elem.Termination;
                end
                if strcmpi(dlg.Type,'equationbased')
                    dlg.Name=elem.Name;
                    dlg.Frequency=elem.Frequency;
                    dlg.Z0=elem.Z0;
                    dlg.LossDB=elem.LossDB;
                    dlg.PhaseVelocity=elem.PhaseVelocity;
                    dlg.IntpType=elem.IntpType;
                    dlg.LineLength=elem.LineLength;
                    dlg.Termination=elem.Termination;
                    dlg.StubMode=elem.StubMode;
                end

                if strcmpi(dlg.Type,'delaylossless')
                    dlg.Name=elem.Name;
                    dlg.Z0=elem.Z0;
                    dlg.TimeDelay=elem.TimeDelay;
                end
                if strcmpi(dlg.Type,'delaylossy')
                    dlg.Name=elem.Name;
                    dlg.Z0=elem.Z0;
                    dlg.LineLength=elem.LineLength;
                    dlg.TimeDelay=elem.TimeDelay;
                    dlg.Resistance=elem.Resistance;
                end
            end

            setFigureKeyPress(dlg);
            resetDialogAccess(dlg)
            if self.Canvas.View.UseAppContainer
                dlg.Parent.notify('DisableCanvas',...
                rf.internal.apps.budget.ElementParameterChangedEventData(1,'ApplyButton','inactive'));
            else
                dlg.Parent.notify('DisableCanvas',...
                rf.internal.apps.budget.ElementParameterChangedEventData(1,'ApplyTag','inactive'));
            end
            enableUIControls(dlg,true);
        end
    end
end


