classdef(Sealed,Hidden)DataConstraints




    properties(Hidden)
        DataTypes(1,:)string{mustBeMember(...
        DataTypes,["double","single","int8"...
        ,"uint8","int16","uint16","int32","uint32"...
        ,"bool","int64","uint64","fixpt-slopebias","fixpt-binary","half","bus"])}=[]
        FixedpointTypes(1,:)string=""
        Dimensions(1,:)string{mustBeMember(...
        Dimensions,["scalar","vector","2dmatrix"...
        ,"ndmatrix"])}=[]
        Complexities(1,:)string{mustBeMember(...
        Complexities,["real","complex"])}=[]
        SignalTypes(1,:)string{mustBeMember(...
        SignalTypes,["sample-based","frame-based"])}=[]
        DimensionModes(1,:)string{mustBeMember(...
        DimensionModes,["fixed-dim","var-dim"])}=[]


        SameWordLengthAsInput(1,:)double=[]
        SameWordLengthAsOutput(1,:)double=[]
        GreaterOrEqualIntegerBitsThanInput(1,:)double=[]
        GreaterOrEqualIntegerBitsThanOutput(1,:)double=[]
        GreaterOrEqualWLExcludingSignBitThanInput(1,:)double=[]
        GreaterOrEqualWLExcludingSignBitThanOutput(1,:)double=[]
        Diagnostic(1,1)string{mustBeMember(...
        Diagnostic,["none","warn","error"])}="error"
        CauseErrorId(1,1)string
    end

    properties(Constant,Hidden,GetAccess=private)
        bitPositions=Simulink.DataConstraints.getValidityAttribs();
    end

    properties(Hidden,Access=private)
        validityStruct;
        supportFixdt(1,1)logical=false;
    end

    methods(Hidden,Access=private)
        function obj=processDT(obj)
            dtvalue=obj.validityStruct.vadilityattribs;
            dataTypes=unique(obj.DataTypes);
            if isempty(dataTypes)
                dtvalue=bitor(dtvalue,obj.bitPositions.s_alldatatypes);
            else
                for i=1:numel(dataTypes)
                    if(any(dataTypes(i)=='double'))
                        dtvalue=bitset(dtvalue,obj.bitPositions.s_double+1);
                    elseif(any(dataTypes(i)=='single'))
                        dtvalue=bitset(dtvalue,obj.bitPositions.s_single+1);
                    elseif(any(dataTypes(i)=='int8'))
                        dtvalue=bitset(dtvalue,obj.bitPositions.s_int8+1);
                    elseif(any(dataTypes(i)=='uint8'))
                        dtvalue=bitset(dtvalue,obj.bitPositions.s_uint8+1);
                    elseif(any(dataTypes(i)=='int16'))
                        dtvalue=bitset(dtvalue,obj.bitPositions.s_int16+1);
                    elseif(any(dataTypes(i)=='uint16'))
                        dtvalue=bitset(dtvalue,obj.bitPositions.s_uint16+1);
                    elseif(any(dataTypes(i)=='int32'))
                        dtvalue=bitset(dtvalue,obj.bitPositions.s_int32+1);
                    elseif(any(dataTypes(i)=='uint32'))
                        dtvalue=bitset(dtvalue,obj.bitPositions.s_uint32+1);
                    elseif(any(dataTypes(i)=='bool'))
                        dtvalue=bitset(dtvalue,obj.bitPositions.s_bool+1);
                    elseif(any(dataTypes(i)=='int64'))
                        dtvalue=bitset(dtvalue,obj.bitPositions.s_int64+1);
                    elseif(any(dataTypes(i)=='uint64'))
                        dtvalue=bitset(dtvalue,obj.bitPositions.s_uint64+1);
                    elseif(any(dataTypes(i)=='fixpt-slopebias'))
                        obj.supportFixdt=true;
                        dtvalue=bitset(dtvalue,obj.bitPositions.s_nonbinfxp+1);
                    elseif(any(dataTypes(i)=='fixpt-binary'))
                        obj.supportFixdt=true;
                        dtvalue=bitset(dtvalue,obj.bitPositions.s_binfxp+1);
                    elseif(any(dataTypes(i)=='half'))
                        dtvalue=bitset(dtvalue,obj.bitPositions.s_half+1);
                    elseif(any(dataTypes(i)=='bus'))
                        dtvalue=bitset(dtvalue,obj.bitPositions.s_bus+1);
                    end

                end
            end
            obj.validityStruct.vadilityattribs=dtvalue;
        end



        function obj=processFixdt(obj)
            obj.validityStruct.signedness=2;
            obj.validityStruct.wordlength={};

            for i=1:numel(obj.FixedpointTypes)
                if(obj.FixedpointTypes(i)~="")
                    [s,wl]=Simulink.DataConstraints.parse_fixdt_string(obj.FixedpointTypes(i));
                    if(obj.supportFixdt)
                        if isempty(obj.validityStruct.signedness)
                            obj.validityStruct.signedness=s;
                        else
                            obj.validityStruct.signedness=Simulink.DataConstraints.mergeSignedBit(s,...
                            obj.validityStruct.signedness);
                        end

                        obj.validityStruct.wordlength=[obj.validityStruct.wordlength,wl];
                    else
                        error('Simulink:DataValidation:FixptNotSupported',...
                        'DataTypes should specify either fixdt-binary or fixdt-slopebiase');
                    end

                end
            end
        end

        function obj=processDims(obj)
            dimvalue=obj.validityStruct.vadilityattribs;
            dimensions=unique(obj.Dimensions);
            if isempty(dimensions)
                dimvalue=bitor(dimvalue,obj.bitPositions.s_alldimensions);
            else
                for i=1:numel(dimensions)
                    if(any(dimensions(i)=='scalar'))
                        dimvalue=bitset(dimvalue,obj.bitPositions.s_scalar+1);
                    elseif(any(dimensions(i)=='vector'))
                        dimvalue=bitset(dimvalue,obj.bitPositions.s_vector+1);
                    elseif(any(dimensions(i)=='2dmatrix'))
                        dimvalue=bitset(dimvalue,obj.bitPositions.s_2dmatrix+1);
                    elseif(any(dimensions(i)=='ndmatrix'))
                        dimvalue=bitset(dimvalue,obj.bitPositions.s_ndmatrix+1);
                    elseif(any(dimensions(i)=='fixed-dim'))
                        dimvalue=bitset(dimvalue,obj.bitPositions.s_fixdim+1);
                    elseif(any(dimensions(i)=='var-dim'))
                        dimvalue=bitset(dimvalue,obj.bitPositions.s_vardim+1);
                    end
                end
            end

            dimModes=unique(obj.DimensionModes);
            if isempty(dimModes)
                dimvalue=bitset(dimvalue,obj.bitPositions.s_fixdim+1);
                dimvalue=bitset(dimvalue,obj.bitPositions.s_vardim+1);
            else
                for i=1:numel(dimModes)
                    if(any(dimModes(i)=='fixed-dim'))
                        dimvalue=bitset(dimvalue,obj.bitPositions.s_fixdim+1);
                    elseif(any(dimModes(i)=='var-dim'))
                        dimvalue=bitset(dimvalue,obj.bitPositions.s_vardim+1);
                    end
                end
            end
            obj.validityStruct.vadilityattribs=dimvalue;
        end

        function obj=processComplex(obj)
            cmplxvalue=obj.validityStruct.vadilityattribs;
            complexities=unique(obj.Complexities);
            if isempty(complexities)
                cmplxvalue=bitor(cmplxvalue,obj.bitPositions.s_allcomplexities);
            else
                for i=1:numel(complexities)
                    if(any(complexities(i)=='real'))
                        cmplxvalue=bitset(cmplxvalue,obj.bitPositions.s_real+1);
                    elseif(any(complexities(i)=='complex'))
                        cmplxvalue=bitset(cmplxvalue,obj.bitPositions.s_complex+1);
                    end
                end
            end
            obj.validityStruct.vadilityattribs=cmplxvalue;
        end

        function obj=processSignalType(obj)
            stvalue=obj.validityStruct.vadilityattribs;
            signaltypes=unique(obj.SignalTypes);
            if isempty(signaltypes)
                stvalue=bitor(stvalue,obj.bitPositions.s_allsignaltypes);
            else
                for i=1:numel(signaltypes)
                    if(any(signaltypes(i)=='sample-based'))
                        stvalue=bitset(stvalue,obj.bitPositions.s_noframe+1);
                    elseif(any(signaltypes(i)=='frame-based'))
                        stvalue=bitset(stvalue,obj.bitPositions.s_yesframe+1);
                    end
                end
            end
            obj.validityStruct.vadilityattribs=stvalue;
        end

        function obj=processCrossPorts(obj)




            obj.validityStruct.samewordlengthasinput=num2cell(obj.SameWordLengthAsInput);
            obj.validityStruct.samewordlengthasoutput=num2cell(obj.SameWordLengthAsOutput);
            obj.validityStruct.integerbitsGEinput=num2cell(obj.GreaterOrEqualIntegerBitsThanInput);
            obj.validityStruct.integerbitsGEoutput=num2cell(obj.GreaterOrEqualIntegerBitsThanOutput);
            obj.validityStruct.wordlengthGEinput=num2cell(obj.GreaterOrEqualWLExcludingSignBitThanInput);
            obj.validityStruct.wordlengthGEoutput=num2cell(obj.GreaterOrEqualWLExcludingSignBitThanOutput);
        end

        function[s,obj]=stringify(obj)
            obj.validityStruct.vadilityattribs=uint64(0);
            obj=processDT(obj);
            obj=processFixdt(obj);
            obj=processDims(obj);
            obj=processComplex(obj);
            obj=processSignalType(obj);
            obj=processCrossPorts(obj);
            switch obj.Diagnostic
            case "none"
                obj.validityStruct.diagnostic=0;
            case "warn"
                obj.validityStruct.diagnostic=1;
            case "error"
                obj.validityStruct.diagnostic=2;
            otherwise
                obj.validityStruct.diagnostic=2;
            end
            obj.validityStruct.extraMsgId=obj.CauseErrorId;
            s=jsonencode(obj.validityStruct);
        end

    end

    methods
        function obj=set.FixedpointTypes(obj,val)
            for i=1:numel(val)
                if(val(i)~="")
                    Simulink.DataConstraints.parse_fixdt_string(val(i));
                end
            end
            obj.FixedpointTypes=val;
        end

        function setDataConstraintsToPort(obj,blkpath,inorout,portidx)

            ports=get_param(blkpath,'PortHandles');
            if isequal(inorout,'Input')
                porthdl=ports.Inport(portidx);
            elseif isequal(inorout,'Output')
                porthdl=ports.Outport(portidx);
            end
            set_param(porthdl,'DataConstraints',stringify(obj));
        end
    end


    methods(Static)

        function val=getFromPort(blkpath,inorout,portidx)

            ports=get_param(blkpath,'PortHandles');
            if isequal(inorout,'Input')
                porthdl=ports.Inport(portidx);
            elseif isequal(inorout,'Output')
                porthdl=ports.Outport(portidx);
            end
            val=jsondecode(get_param(porthdl,'DataConstraints'));

        end


        function clearForPort(blkpath,inorout,portidx)

            ports=get_param(blkpath,'PortHandles');
            if isequal(inorout,'Input')
                porthdl=ports.Inport(portidx);
            elseif isequal(inorout,'Output')
                porthdl=ports.Outport(portidx);
            end
            set_param(porthdl,'DataConstraints',"");
        end



        function key=getPortConstraintKey(blkType,inorout,portidx)
            if isequal(inorout,'Input')
                key=[blkType,'_In_',int2str(portidx-1)];
            elseif isequal(inorout,'Output')
                key=[blkType,'_Out_',int2str(portidx-1)];
            end
        end


        function r=getAllBlockConstraintsForPort(blkpath,inorout,portidx)
            narginchk(3,3);
            r=struct([]);

            if isempty(blkpath)
                return
            end


            key=Simulink.DataConstraints.getPortConstraintKey(get_param(blkpath,'BlockType'),...
            inorout,portidx);
            r=Simulink.DataConstraints.getAllBlockConstraintsByPortKey(key);
        end


        function r=getAllBlockConstraintsByPortKey(key)
            table=Simulink.DataConstraints.getBlockConstraintsTable();

            constraints=table.getByKey(key);

            for i=1:numel(constraints)
                r(i).Condition=Simulink.DataConstraints.getConstraintCondition(...
                constraints(i).constraint.constraintContext);
                r(i).Validity=Simulink.DataConstraints.decodeValidityAttribs(...
                constraints(i).constraint.validityValue);
            end

        end


        function r=getActiveBlockConstraintsForPort(blkpath,inorout,portidx)
            narginchk(3,3);

            r=struct([]);
            if isempty(blkpath)
                return
            end

            key=Simulink.DataConstraints.getPortConstraintKey(get_param(blkpath,'BlockType'),...
            inorout,portidx);

            table=Simulink.DataConstraints.getBlockConstraintsTable();

            constraints=table.getByKey(key);

            activeIndex=1;
            for i=1:numel(constraints)
                if(Simulink.DataConstraints.isConditionSatisfied(blkpath,...
                    constraints(i).constraint.constraintContext))
                    r(activeIndex).Condition=Simulink.DataConstraints.getConstraintCondition(...
                    constraints(i).constraint.constraintContext);
                    r(activeIndex).Validity=Simulink.DataConstraints.decodeValidityAttribs(...
                    constraints(i).constraint.validityValue);
                    activeIndex=activeIndex+1;
                end
            end
        end

    end


    methods(Static,Hidden)
        function out=getValidityAttribs()



            out.s_double=0;
            out.s_single=1;
            out.s_int8=2;
            out.s_uint8=3;
            out.s_int16=4;
            out.s_uint16=5;
            out.s_int32=6;
            out.s_uint32=7;
            out.s_bool=8;
            out.s_int64=9;
            out.s_uint64=10;
            out.s_enum=11;
            out.s_nonbinfxp=12;
            out.s_binfxp=13;
            out.s_string=14;
            out.s_half=15;
            out.s_bus=16;
            out.s_alldatatypes=Simulink.DataConstraints.setBits(out.s_double+1:out.s_bus+1);

            out.s_complex=17;
            out.s_real=18;
            out.s_allcomplexities=Simulink.DataConstraints.setBits([out.s_complex+1,out.s_real+1]);

            out.s_scalar=19;
            out.s_vector=20;
            out.s_2dmatrix=23;
            out.s_ndmatrix=24;
            out.s_alldimensions=Simulink.DataConstraints.setBits(out.s_scalar+1:out.s_ndmatrix+1);





            out.s_fixdim=34;
            out.s_vardim=35;

            out.s_alldimsmodes=Simulink.DataConstraints.setBits([out.s_fixdim+1,out.s_vardim+1]);

            out.s_noframe=36;
            out.s_yesframe=37;

            out.s_allsignaltypes=Simulink.DataConstraints.setBits([out.s_noframe+1,out.s_yesframe+1]);
        end



        function out=setBits(in)
            out=uint64(0);
            for i=1:numel(in)
                out=bitset(out,in(i));
            end
        end


        function out=isConditionSatisfied(blkpath,in)
            if isempty(in)

                out=true;
            else

                for outidx=1:in.Size()
                    isParamValueInTheVList=false;
                    pvs=in(outidx);
                    act_val=get_param(blkpath,pvs.Name);

                    for i=1:pvs.Value.Size()


                        exp_val=pvs.Value(i);
                        if(isequal(act_val,exp_val{:}))
                            isParamValueInTheVList=true;

                            break;
                        end
                    end


                    if(~isParamValueInTheVList)
                        out=false;
                        return;
                    end
                end


                out=true;
            end
        end


        function retval=getConstraintCondition(in)
            retval=struct([]);
            for condIndex=1:in.Size()
                pvs=in(condIndex);

                values=cell(1,pvs.Value.Size());
                for pvalueIndex=1:pvs.Value.Size()
                    val=pvs.Value(pvalueIndex);
                    values{pvalueIndex}=val{:};
                end
                retval(condIndex).Name=pvs.Name;
                retval(condIndex).Value=values;
            end
        end



        function table=getConstraintsTableByType(type)
            table=[];
            model=SimulinkInternal.getBlkConstraintsModel();
            blkConstraintsTable=model.topLevelElements;
            if~isempty(blkConstraintsTable)
                for i=1:numel(blkConstraintsTable)
                    if isa(blkConstraintsTable(i),type)
                        table=blkConstraintsTable(i).constraints;
                    end
                end
            end
        end


        function table=getBlockConstraintsTable()
            table=Simulink.DataConstraints.getConstraintsTableByType(...
            'Simulink.DataValidity.Internal.SlBlkConstraintsMap');
        end


        function table=getBlockRunTimeConstraintsTable()
            table=Simulink.DataConstraints.getConstraintsTableByType(...
            'Simulink.DataValidity.SlBlkRuntimeConstraintsMap');
        end



        function result=decodeValidityAttribs(in)

            result=struct(...
            'Datatype',[],...
            'Dimension',[],...
            'Complexity',[]);

            datatypeIdx=1;
            cmplxIdx=1;
            dimsIdx=1;


            bitPositions=Simulink.DataConstraints.getValidityAttribs();
            for outidx=1:numel(in)
                validityBits=in(outidx);

                if(bitget(validityBits,bitPositions.s_double+1))
                    dataTypes{datatypeIdx}='double';%#ok<*AGROW>
                    datatypeIdx=datatypeIdx+1;
                end

                if(bitget(validityBits,bitPositions.s_single+1))
                    dataTypes{datatypeIdx}='single';
                    datatypeIdx=datatypeIdx+1;
                end

                if(bitget(validityBits,bitPositions.s_int8+1))
                    dataTypes{datatypeIdx}='int8';
                    datatypeIdx=datatypeIdx+1;
                end

                if(bitget(validityBits,bitPositions.s_uint8+1))
                    dataTypes{datatypeIdx}='uint8';
                    datatypeIdx=datatypeIdx+1;
                end

                if(bitget(validityBits,bitPositions.s_int16+1))
                    dataTypes{datatypeIdx}='int16';
                    datatypeIdx=datatypeIdx+1;
                end

                if(bitget(validityBits,bitPositions.s_uint16+1))
                    dataTypes{datatypeIdx}='uint16';
                    datatypeIdx=datatypeIdx+1;
                end

                if(bitget(validityBits,bitPositions.s_int32+1))
                    dataTypes{datatypeIdx}='int32';
                    datatypeIdx=datatypeIdx+1;
                end

                if(bitget(validityBits,bitPositions.s_uint32+1))
                    dataTypes{datatypeIdx}='uint32';
                    datatypeIdx=datatypeIdx+1;
                end

                if(bitget(validityBits,bitPositions.s_bool+1))
                    dataTypes{datatypeIdx}='bool';
                    datatypeIdx=datatypeIdx+1;
                end

                if(bitget(validityBits,bitPositions.s_int64+1))
                    dataTypes{datatypeIdx}='int64';
                    datatypeIdx=datatypeIdx+1;
                end

                if(bitget(validityBits,bitPositions.s_uint64+1))
                    dataTypes{datatypeIdx}='uint64';
                    datatypeIdx=datatypeIdx+1;
                end

                if(bitget(validityBits,bitPositions.s_nonbinfxp+1))
                    dataTypes{datatypeIdx}='fixed point';
                    datatypeIdx=datatypeIdx+1;
                end

                if(bitget(validityBits,bitPositions.s_binfxp+1))
                    dataTypes{datatypeIdx}='binary fixed point';
                    datatypeIdx=datatypeIdx+1;
                end

                if(bitget(validityBits,bitPositions.s_half+1))
                    dataTypes{datatypeIdx}='half';
                    datatypeIdx=datatypeIdx+1;
                end

                if(bitget(validityBits,bitPositions.s_bus+1))
                    dataTypes{datatypeIdx}='bus';
                    datatypeIdx=datatypeIdx+1;
                end


                if(bitget(validityBits,bitPositions.s_complex+1))
                    complexities{cmplxIdx}='complex';
                    cmplxIdx=cmplxIdx+1;
                end
                if(bitget(validityBits,bitPositions.s_real+1))
                    complexities{cmplxIdx}='real';
                    cmplxIdx=cmplxIdx+1;
                end


                if(bitget(validityBits,bitPositions.s_scalar+1))
                    dimensions{dimsIdx}='scalar';
                    dimsIdx=dimsIdx+1;
                end

                if(bitget(validityBits,bitPositions.s_vector+1))
                    dimensions{dimsIdx}='vector';
                    dimsIdx=dimsIdx+1;
                end

                if(bitget(validityBits,bitPositions.s_2dmatrix+1))
                    dimensions{dimsIdx}='2d matrix';
                    dimsIdx=dimsIdx+1;
                end

                if(bitget(validityBits,bitPositions.s_ndmatrix+1))
                    dimensions{dimsIdx}='Nd matrix';
                    dimsIdx=dimsIdx+1;
                end

            end

            result.Datatype=dataTypes;
            result.Complexity=complexities;
            result.Dimension=dimensions;
        end
    end

    methods(Static,Hidden,Access=private)
        function[signedness,wl]=parse_fixdt_string(str)
            results=regexp(str,'(s|u)*fix(\d+)_(\*|en(\d+)|e(\d+))','tokens','once');

            if(numel(results)~=3)
                error('Simulink:DataValidation:invalidFixedpointTypes',...
                '%s is not an valid FixedpointTypes value.',str);
            end

            if isempty(results{1})
                signedness=2;
            elseif(isequal(results{1},'u'))
                signedness=0;
            elseif(isequal(results{1},'s'))
                signedness=1;
            end

            wl=str2double(results{2});

            raw_fl_str=results{3};
            if~isempty(raw_fl_str)
                fl_val=regexp(raw_fl_str,'e(\d+)|en(\d+)','tokens','once');
                if~isempty(fl_val)
                    error('Simulink:DataValidation:invalidFixedpointTypes',...
                    'Can not add %s as the fraction length constraint',fl_val{:});
                end
            else

            end

        end

        function y=mergeSignedBit(u1,u2)
            if(u1==2)

                y=u2;
                return
            end

            if(u2==2)

                y=u1;
                return;
            end

            if xor(u1,u2)
                error('Simulink:DataValidation:invalidFixedpointConstraint',...
                'Two fixed point constraints have a conflict signed bit constraint');
            end

            y=u1;
        end

    end
end


