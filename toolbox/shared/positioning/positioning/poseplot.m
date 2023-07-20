function hh=poseplot(varargin)
















































    [parent,args]=axescheck(varargin{:});


    [navframe,args,nargs,extraArgs]=navframecheck(args{:});


    orient=quaternion.ones;
    pos=[0,0,0];
    if(nargs==2)
        orient=positioning.graphics.chart.PosePatch.validateOrientation(args{1});
        pos=positioning.graphics.chart.PosePatch.validatePosition(args{2});
    elseif(nargs==1)
        arg=args{1};
        if isa(arg,'quaternion')
            orient=positioning.graphics.chart.PosePatch.validateOrientation(arg);
        elseif(isa(arg,'numeric')&&(numel(arg)==3))
            pos=positioning.graphics.chart.PosePatch.validatePosition(arg);
        else
            orient=positioning.graphics.chart.PosePatch.validateOrientation(arg);
        end
    end


    if isempty(parent)||ishghandle(parent,'axes')
        ax=newplot(parent);
    else
        error(message('MATLAB:hg:InvalidParent','poseplot',class(parent)));
    end


    isHoldOff=any(strcmpi(ax.NextPlot,{'replace','replaceall','replacechildren'}));


    isMeshFileSpecified=cellfun(@(x)startsWith("meshfilename",x,"IgnoreCase",true),extraArgs(1:2:end));
    extraArgs=configuremeshfile(extraArgs,isMeshFileSpecified,ax,navframe,isHoldOff);


    h=positioning.graphics.chart.PosePatch('Parent',ax,...
    'Orientation',orient,'Position',pos,extraArgs{:});



    isSpecified=cellfun(@(x)startsWith("patchfacecolor",x,"IgnoreCase",true),extraArgs(1:2:end));
    useColorOrder=~any(isSpecified);
    if useColorOrder
        assignSeriesIndex(h);
    end

    configureaxes(ax,navframe,isHoldOff);


    if(nargout>0)
        hh=h;
    end

end

function configureaxes(ax,navframe,isHoldOff)


    if isHoldOff


        if strcmp(navframe,'NED')
            ax.YDir='reverse';
            ax.ZDir='reverse';
        end

        view(ax,3);



        if~strcmpi(ax.NextPlot,'replacechildren')
            axis(ax,'equal');

            grid(ax,'on');
            grid(ax,'minor');
        end
    else

        xdir=ax.XDir;
        ydir=ax.YDir;
        zdir=ax.ZDir;
        isNormal=strcmp({xdir,ydir,zdir},'normal');


        isZDirValid=~xor(strcmp(navframe,'NED'),~isNormal(3));
        if~isZDirValid
            warning(message("shared_positioning:poseplot:InvalidZDirection",navframe));
        end


        isRightHandedSystem=((nnz(isNormal)==1)||(nnz(isNormal)==3));
        if~isRightHandedSystem
            warning(message("shared_positioning:poseplot:LeftHandedSystem"));
        end
    end
end

function[navframe,args,numPosArgs,extraArgs]=navframecheck(varargin)



    navframe='NED';
    args=varargin;
    nargs=nargin;
    numPosArgs=nargs;
    extraArgs={};
    for i=1:nargs
        in=args{i};
        if(isa(in,'string')||isa(in,'char'))
            tf=startsWith(["ENU","NED"],in,'IgnoreCase',true);
            if(nnz(tf)==1)
                navframe=validatestring(in,{'ENU','NED'},...
                'poseplot','navframe');
                args(i)=[];
            end
            extraArgs=args(i:end);
            args=args(1:i-1);
            numPosArgs=numel(args);

            break;
        end

    end
end

function extraArgs=configuremeshfile(extraArgs,isMeshFileSpecified,ax,navframe,isHoldOff)
    idx=find(isMeshFileSpecified);
    if isempty(idx)
        return;
    end
    meshfile=extraArgs{2*idx};
    tr=stlread(meshfile);
    vertices=tr.Points;
    faces=tr.ConnectivityList;
    if isHoldOff
        if strcmp(navframe,'NED')
            vertices(:,2:3)=-vertices(:,2:3);
        end
    else
        if strcmp(ax.ZDir,'reverse')
            vertices(:,3)=-vertices(:,3);
        end
        if strcmp(ax.YDir,'reverse')
            vertices(:,2)=-vertices(:,2);
        end
        if strcmp(ax.XDir,'reverse')
            vertices(:,1)=-vertices(:,1);
        end
    end
    vertices=vertices-mean(vertices,1);
    extraArgs(end+1:end+4)={'pMeshVertices_I',vertices,'pMeshFaces_I',faces};
end
