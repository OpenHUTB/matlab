classdef MutualInductance_class<ConvClass&handle



    properties

        OldParam=struct(...
        'NumberOfWindings',[],...
        'SelfImpedance1',[],...
        'SelfImpedance2',[],...
        'SelfImpedance3',[],...
        'MutualImpedance',[],...
        'InductanceMatrix',[],...
        'ResistanceMatrix',[]...
        )


        OldDropdown=struct(...
        'TypeOfMutual',[],...
        'Measurements',[],...
        'ThreeWindings',[]...
        )


        NewDirectParam=struct(...
        )


        NewDerivedParam=struct(...
        'Rm',[],...
        'Ra',[],...
        'Rb',[],...
        'Rc',[],...
        'La',[],...
        'Lb',[],...
        'Lc',[],...
        'Lmab',[],...
        'Lmac',[],...
        'Lmbc',[],...
        'R1',[],...
        'R2',[],...
        'L1',[],...
        'L2',[],...
        'Lm',[]...
        )


        NewDropdown=struct(...
        )


        BlockOption={...
        {'TypeOfMutual','Two or three windings with equal mutual terms';'ThreeWindings','on'},'three';...
        {'TypeOfMutual','Two or three windings with equal mutual terms';'ThreeWindings','off'},'two';...
        {'TypeOfMutual','Generalized mutual inductance';'NumberOfWindings','3'},'three';...
        {'TypeOfMutual','Generalized mutual inductance';'NumberOfWindings','2'},'two';...
        {'TypeOfMutual','Generalized mutual inductance'},'Blank';...
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib/Elements/Mutual Inductance'
        NewPath='elec_conv_MutualInductance/MutualInductance'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end


        function obj=MutualInductance_class(TypeOfMutual,ThreeWindings,SelfImpedance1,SelfImpedance2,SelfImpedance3,MutualImpedance,NumberOfWindings,ResistanceMatrix,InductanceMatrix)
            if nargin>0
                obj.OldDropdown.TypeOfMutual=TypeOfMutual;
                obj.OldDropdown.ThreeWindings=ThreeWindings;
                obj.OldParam.SelfImpedance1=SelfImpedance1;
                obj.OldParam.SelfImpedance2=SelfImpedance2;
                obj.OldParam.SelfImpedance3=SelfImpedance3;
                obj.OldParam.MutualImpedance=MutualImpedance;
                obj.OldParam.NumberOfWindings=NumberOfWindings;
                obj.OldParam.ResistanceMatrix=ResistanceMatrix;
                obj.OldParam.InductanceMatrix=InductanceMatrix;
            end
        end

        function obj=objParamMappingDerived(obj)

            switch obj.OldDropdown.TypeOfMutual
            case 'Two or three windings with equal mutual terms'
                if strcmp(obj.OldDropdown.ThreeWindings,'on')
                    obj.NewDerivedParam.Ra=obj.OldParam.SelfImpedance1(1);
                    obj.NewDerivedParam.Rb=obj.OldParam.SelfImpedance2(1);
                    obj.NewDerivedParam.Rc=obj.OldParam.SelfImpedance3(1);
                    obj.NewDerivedParam.Rm=obj.OldParam.MutualImpedance(1);
                    obj.NewDerivedParam.La=obj.OldParam.SelfImpedance1(2);
                    obj.NewDerivedParam.Lb=obj.OldParam.SelfImpedance2(2);
                    obj.NewDerivedParam.Lc=obj.OldParam.SelfImpedance3(2);
                    obj.NewDerivedParam.Lmab=obj.OldParam.MutualImpedance(2);
                    obj.NewDerivedParam.Lmbc=obj.OldParam.MutualImpedance(2);
                    obj.NewDerivedParam.Lmac=obj.OldParam.MutualImpedance(2);
                    obj.NewDerivedParam.R1=1;
                    obj.NewDerivedParam.R2=1;
                    obj.NewDerivedParam.L1=1;
                    obj.NewDerivedParam.L2=1;
                    obj.NewDerivedParam.Lm=1;
                else
                    obj.NewDerivedParam.R1=obj.OldParam.SelfImpedance1(1);
                    obj.NewDerivedParam.R2=obj.OldParam.SelfImpedance2(1);
                    obj.NewDerivedParam.Rm=obj.OldParam.MutualImpedance(1);
                    obj.NewDerivedParam.L1=obj.OldParam.SelfImpedance1(2);
                    obj.NewDerivedParam.L2=obj.OldParam.SelfImpedance2(2);
                    obj.NewDerivedParam.Lm=obj.OldParam.MutualImpedance(2);
                    obj.NewDerivedParam.Ra=1;
                    obj.NewDerivedParam.Rb=1;
                    obj.NewDerivedParam.Rc=1;
                    obj.NewDerivedParam.La=1;
                    obj.NewDerivedParam.Lb=1;
                    obj.NewDerivedParam.Lc=1;
                    obj.NewDerivedParam.Lmab=1;
                    obj.NewDerivedParam.Lmbc=1;
                    obj.NewDerivedParam.Lmac=1;
                end
            case 'Generalized mutual inductance'
                if obj.OldParam.NumberOfWindings==3
                    obj.NewDerivedParam.Ra=obj.OldParam.ResistanceMatrix(1,1);
                    obj.NewDerivedParam.Rb=obj.OldParam.ResistanceMatrix(2,2);
                    obj.NewDerivedParam.Rc=obj.OldParam.ResistanceMatrix(3,3);
                    obj.NewDerivedParam.Rm=obj.OldParam.ResistanceMatrix(1,2);
                    obj.NewDerivedParam.La=obj.OldParam.InductanceMatrix(1,1);
                    obj.NewDerivedParam.Lb=obj.OldParam.InductanceMatrix(2,2);
                    obj.NewDerivedParam.Lc=obj.OldParam.InductanceMatrix(3,3);
                    obj.NewDerivedParam.Lmab=obj.OldParam.InductanceMatrix(1,2);
                    obj.NewDerivedParam.Lmbc=obj.OldParam.InductanceMatrix(2,3);
                    obj.NewDerivedParam.Lmac=obj.OldParam.InductanceMatrix(1,3);
                    obj.NewDerivedParam.R1=1;
                    obj.NewDerivedParam.R2=1;
                    obj.NewDerivedParam.L1=1;
                    obj.NewDerivedParam.L2=1;
                    obj.NewDerivedParam.Lm=1;
                elseif obj.OldParam.NumberOfWindings==2
                    obj.NewDerivedParam.R1=obj.OldParam.ResistanceMatrix(1,1);
                    obj.NewDerivedParam.R2=obj.OldParam.ResistanceMatrix(2,2);
                    obj.NewDerivedParam.Rm=obj.OldParam.ResistanceMatrix(1,2);
                    obj.NewDerivedParam.L1=obj.OldParam.InductanceMatrix(1,1);
                    obj.NewDerivedParam.L2=obj.OldParam.InductanceMatrix(2,2);
                    obj.NewDerivedParam.Lm=obj.OldParam.InductanceMatrix(1,2);
                    obj.NewDerivedParam.Ra=1;
                    obj.NewDerivedParam.Rb=1;
                    obj.NewDerivedParam.Rc=1;
                    obj.NewDerivedParam.La=1;
                    obj.NewDerivedParam.Lb=1;
                    obj.NewDerivedParam.Lc=1;
                    obj.NewDerivedParam.Lmab=1;
                    obj.NewDerivedParam.Lmbc=1;
                    obj.NewDerivedParam.Lmac=1;
                else

                end
            otherwise

            end

        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();

            logObj.addMessage(obj,'CustomMessage','The inductor current might start from an undesired value.');
            logObj.addMessage(obj,'CustomMessage','Please make necessary changes in the block ''Variables'' tab or select ''Start simulation from steady state'' in the corresponding ''Solver Configuration'' block.');


            if strcmp(obj.OldDropdown.TypeOfMutual,'Generalized mutual inductance')&&obj.OldParam.NumberOfWindings>3
                logObj.addMessage(obj,'OptionNotSupportedNoImport','Type of mutual inductance','Generalized mutual inductance with more than 3 windings');
            end

            if strcmp(obj.OldDropdown.TypeOfMutual,'Generalized mutual inductance')&&obj.OldParam.NumberOfWindings<2
                logObj.addMessage(obj,'OptionNotSupportedNoImport','Type of mutual inductance','Generalized mutual inductance with less than 2 windings');
            end

            switch obj.OldDropdown.Measurements
            case 'None'

            case 'Winding voltages'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Winding voltages');
            case 'Winding currents'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Winding currents');
            case 'Winding voltages and currents'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Winding voltages and currents');
            end
        end
    end

end
