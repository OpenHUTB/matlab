


classdef RollThresholdConstraint<slci.compatibility.Constraint

    properties(Access=private)
        fMin=[];
        fMax=[];
        fRollThreshold=[];
    end
    methods

        function obj=RollThresholdConstraint()
            obj.setEnum('RollThreshold');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end

        function out=getDescription(aObj)%#ok
            out='There are currently two places where nested loops could be generated. 1) Matrix operations and 2) math transpose functions. SLCI does not support partially rolled loop if the Loop unrolling threshold is set to a value that triggers partial loop unrolling. For 1) matrix multiplication u1[mxn] * u2[n*p] = y[m*p], Roll threshold should be either less than or equal to m OR greater than (m*n*p); For 2) transpose functions, TRANSPOSE(u[mxn]), roll threshold should be either less or equal to n OR greater than (m*n).';
        end








        function out=check(aObj)
            out=[];
            allBlocks=aObj.ParentModel().getBlocks();
            set=slci.compatibility.UniqueBlockSet;
            aObj.fRollThreshold=get_param(aObj.ParentModel().getName(),'RollThreshold');
            for i=1:numel(allBlocks)
                min=[];
                max=[];

                blk=allBlocks{i};


                obj=blk.getParam('Object');
                if obj.isPostCompileVirtual
                    continue;
                end

                blkH=blk.getParam('Handle');
                blk_type=get_param(blkH,'BlockType');
                if strcmp(blk_type,'Product')
                    [min,max]=checkProduct(blkH);
                elseif strcmp(blk_type,'Gain')
                    [min,max]=checkGain(blkH);
                elseif strcmp(blk_type,'Math')
                    [min,max]=checkMath(blkH);
                end
                if(isIncompatible(min,max,aObj.fRollThreshold))
                    set.AddBlock(blkH);
                end

                [aObj.fMin,aObj.fMax]=updateMinMax(aObj.fMin,aObj.fMax,min,max);
            end
            if set.GetLength()>0
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'RollThreshold',...
                set.GetBlockStr());
                out.setObjectsInvolved(set.GetBlockCell());
            end
        end

        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,status,varargin)
            SubTitle=DAStudio.message('Slci:compatibility:RollThresholdConstraintSubTitle');
            Information=DAStudio.message('Slci:compatibility:RollThresholdConstraintInfo');
            if status
                RecAction=DAStudio.message('Slci:compatibility:RollThresholdConstraintRecAction',aObj.ParentModel.getName,0,0);
                StatusText=DAStudio.message('Slci:compatibility:RollThresholdConstraintPass');
            else
                RecAction=DAStudio.message('Slci:compatibility:RollThresholdConstraintRecAction',aObj.ParentModel.getName,aObj.fMin,aObj.fMax);
                StatusText=DAStudio.message('Slci:compatibility:RollThresholdConstraintWarn',aObj.ParentModel.getName,aObj.fRollThreshold);
            end
        end
    end

end

function out=isIncompatible(min,max,RollThreshold)
    out=(~isempty(min)&&~isempty(max)...
    &&((RollThreshold>min)&&(min~=1))...
    &&((RollThreshold<=max)&&(max~=1))...
    &&(RollThreshold~=1));
end

function[min,max]=checkProduct(blkH)
    min=[];
    max=[];






    if(strcmp(get_param(blkH,'Multiplication'),'Matrix(*)'))
        port_hdls=get_param(blkH,'PortHandles');
        num_ports=numel(port_hdls.Inport);
        assert(num_ports>0);
        port_obj=get_param(port_hdls.Inport(1),'Object');
        u1_dim=port_obj.CompiledPortDimensions;
        for port_idx=2:(num_ports)
            port_obj=get_param(port_hdls.Inport(port_idx),'Object');
            u2_dim=port_obj.CompiledPortDimensions;

            if(u1_dim(1)==1)
                u1_dim=[u1_dim,1];
                u1_dim(1)=2;
            end
            if(u2_dim(1)==1)
                u2_dim=[u1_dim,1];
                u2_dim(1)=2;
            end

            assert(u1_dim(1)==2);
            assert(u2_dim(1)==2);

            curr_min=getMin(u1_dim(3),u2_dim(3),u1_dim(2));

            curr_max=u1_dim(2)*u1_dim(3)*u2_dim(3);


            [min,max]=updateMinMax(min,max,curr_min,curr_max);


            u1_dim(3)=u2_dim(3);
        end
    end
end


function[min,max]=checkGain(blkH)
    min=[];
    max=[];















    Multiplication=get_param(blkH,'Multiplication');

    is_k_by_u=strcmp(Multiplication,'Matrix(K*u)')...
    ||strcmp(Multiplication,'Matrix(K*u) (u vector)');
    is_u_by_k=strcmp(Multiplication,'Matrix(u*K)');
    if(is_k_by_u||is_u_by_k)
        port_hdls=get_param(blkH,'PortHandles');
        port_obj=get_param(port_hdls.Inport(1),'Object');
        dim_u=port_obj.CompiledPortDimensions;
        port_obj=get_param(port_hdls.Outport(1),'Object');
        dim_y=port_obj.CompiledPortDimensions;
        if(dim_u(1)==1)
            dim_u=[dim_u,1];
            dim_u(1)=2;
        end
        if(dim_y(1)==1)
            dim_y=[dim_y,1];
            dim_y(1)=2;
        end
        assert(dim_y(1)==2);







        if(is_k_by_u)
            min=getMin(dim_u(2),dim_y(3),dim_y(2));
            max=dim_u(2)*dim_y(3)*dim_y(2);
        else
            min=getMin(dim_u(3),dim_y(3),dim_y(2));
            max=dim_u(3)*dim_y(3)*dim_y(2);
        end
    end
end

function[min,max]=checkMath(blkH)
    min=[];
    max=[];

    Operator=get_param(blkH,'Operator');


    if(strcmp(Operator,'transpose'))
        port_hdls=get_param(blkH,'PortHandles');
        assert(numel(port_hdls)==1);
        port_obj=get_param(port_hdls.Inport(1),'Object');
        dim_u=port_obj.CompiledPortDimensions;

        if(dim_u(1)==2)

            min=getMin(dim_u(3),dim_u(2),1);

            max=dim_u(3)*dim_u(2);
        end
    end
end





function min=getMin(n,p,m)

    min=n;

    if(min==1)
        min=p;

        if(min==1)
            min=m;
        end
    end
end

function[min,max]=updateMinMax(g_min,g_max,curr_min,curr_max)

    min=g_min;
    max=g_max;

    if(isempty(min))
        min=curr_min;
    elseif~isempty(curr_min)&&curr_min<min&&(curr_min~=1)
        min=curr_min;
    end

    if(isempty(max))
        max=curr_max;
    elseif~isempty(curr_max)&&curr_max>max
        max=curr_max;
    end
end

