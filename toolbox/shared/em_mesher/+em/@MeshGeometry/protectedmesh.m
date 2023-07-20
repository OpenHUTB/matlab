function varargout=protectedmesh(obj,varargin)



















































    if nargin>1
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    if nargin>11&&strcmp(obj.MesherStruct.MeshingChoice,'manual')
        error(message('antenna:antennaerrors:IncorrectNumArguments','input','input','4'));
    end

    if nargin==2
        if isnumeric(varargin{1})
            error(message('antenna:antennaerrors:Unsupported',...
            'Frequency or wavelength','a second input to mesh'));
        end
    end



    tfm=zeros(1,nargin-1);
    for i=1:nargin-1
        tfm(i)=strcmpi(varargin{i},'MaxEdgeLength');
    end


    minEL=zeros(1,nargin-1);
    for i=1:nargin-1
        minEL(i)=strcmpi(varargin{i},'MinEdgeLength');
    end


    grate=zeros(1,nargin-1);
    for i=1:nargin-1
        grate(i)=strcmpi(varargin{i},'GrowthRate');
    end


    if nargin>=2&&(any(tfm)||any(minEL)||any(grate))&&strcmp(obj.MesherStruct.MeshingChoice,'auto')
        obj.MesherStruct.MeshingChoice='manual';
    end



    if nargin<2
        if isempty(obj.MesherStruct.Mesh.p)&&(~isa(obj,'platform')&&...
            ~(isa(obj,'customAntennaStl')&&obj.UseFileAsMesh))...
            &&~isa(obj,'em.internal.stl.Stl')





            if strcmp(obj.MesherStruct.MeshingChoice,'auto')
                warningNoMesh(obj);
            end
        end



        meshnewstructure(obj);
        if isa(obj,'pcbStack')||isa(obj,'em.PCBStructures')||isa(obj,'pcbComponent')
            meshControlOptions=parsePcbStackMeshInputs(obj,varargin{:});
        else
            meshControlOptions=parseMeshInputs(obj,varargin{:});
        end
    else

        if isa(obj,'pcbStack')||isa(obj,'em.PCBStructures')||isa(obj,'pcbComponent')
            meshControlOptions=parsePcbStackMeshInputs(obj,varargin{:});
            if(meshControlOptions.Hmax>0)
                updateMeshForPcbStack(obj,meshControlOptions);
                obj.MesherStruct.Mesh.numEdges=[];

            end
        else
            if(isa(obj,'platform')&&(obj.UseFileAsMesh))||(isa(obj,'customAntennaStl')&&(obj.UseFileAsMesh))
                warning(message('antenna:antennaerrors:RemeshRequestedOnUseFileAsMesh'));
            end
            if(isa(obj,'customDualReflectors')&&~(obj.RemeshReflectors))
                warning(message('antenna:antennaerrors:RemeshRequestedOnRemeshReflectors'));
            end
            meshControlOptions=parseMeshInputs(obj,varargin{:});



            checkMinel=(any(minEL)||any(grate))&&~any(tfm)&&...
            isempty(obj.MesherStruct.Mesh.p);


            if(any(tfm)||any(minEL)||any(grate))&&~checkMinel
                checkMinElGrate(obj,minEL,grate);
                updateMesh(obj,meshControlOptions)

                obj.MesherStruct.Mesh.numEdges=[];
            end
            if checkMinel&&nargout==1
                warningNoMesh(obj);
            end
        end


        meshnewstructure(obj);
    end


    if nargout==0
        if isempty(obj.MesherStruct.Mesh.p)
            show(obj);
            if nargin>1
                warningNoMesh(obj);
            end
            return;
        else
            if strcmpi(class(obj),'planeWaveExcitation')
                if isa(obj.Element,'platform')||isa(obj.Element,'em.internal.stl.Stl')
                    feedwidth=0;
                    feedLocation=[];
                else
                    feedwidth=getFeedWidth(obj.Element);
                    feedLocation=obj.Element.FeedLocation;
                end
            elseif isa(obj,'platform')||isa(obj,'em.internal.stl.Stl')
                feedwidth=0;
                feedLocation=[];
            else
                feedwidth=getFeedWidth(obj);
                feedLocation=obj.FeedLocation;
            end
            hfig=gcf;
            if~isempty(get(groot,'CurrentFigure'))
                clf(hfig);
            end

            [~,antennaColor]=em.MeshGeometry.getMetalInfo(...
            obj.MesherStruct.metalname);

            if isfield(obj.MesherStruct,'infGP')&&obj.MesherStruct.infGP
                if strcmpi(class(obj),'infiniteArray')&&strcmpi(class(obj.Element),'pcbStack')
                    sizeT=size(obj.MesherStruct.Mesh.t,2);
                else
                    if isempty(obj.MesherStruct.Mesh.T)
                        if obj.MesherStruct.Mesh.Eps_r>1
                            sizeT=size(obj.MesherStruct.Mesh.t,2);
                        else
                            sizeT=size(obj.MesherStruct.Mesh.t,2)/2;
                        end
                    else
                        sizeT=size(obj.MesherStruct.Mesh.t,2);
                    end
                end

            else
                sizeT=size(obj.MesherStruct.Mesh.t,2);
            end
            if isprop(obj,'ViewAngle')
                ang=obj.ViewAngle;
            else
                ang=[-38,30];
            end
            if any(strcmpi(meshControlOptions.View,{'metal','all'}))
                em.MeshGeometry.viewmesh(obj.MesherStruct.Mesh.p,...
                obj.MesherStruct.Mesh.t(:,1:sizeT),feedwidth,...
                feedLocation,obj.MesherStruct.metalname,ang);
                if isfield(obj.MesherStruct,'LoadPatch')&&...
                    ~isempty(obj.MesherStruct.LoadPatch)
                    patch(obj.MesherStruct.LoadPatch);
                end
                title('Metal mesh');
            end
            set(hfig,'Tag','mesh');
            try
                set(hfig,'NextPlot','replace');
            catch
            end

            addmeshtable(obj,hfig);
            addTetMesh(obj,meshControlOptions);

            if iscell(obj.MesherStruct.Geometry)
                BorderVertices=cell2mat(cellfun(@(x)x.BorderVertices,...
                obj.MesherStruct.Geometry','UniformOutput',false));
                X=BorderVertices(:,1);
                Y=BorderVertices(:,2);
                Z=BorderVertices(:,3);
            else
                X=obj.MesherStruct.Geometry.BorderVertices(:,1);
                Y=obj.MesherStruct.Geometry.BorderVertices(:,2);
                Z=obj.MesherStruct.Geometry.BorderVertices(:,3);
            end
            em.MeshGeometry.decoratefigureandaxes(X,Y,Z,'');
            slicer=meshControlOptions.slicer;

            if strcmpi(slicer,'on')
                slicer=1;
            elseif strcmpi(meshControlOptions.slicer,'off')
                slicer=0;
            end

            if slicer
                si=cad.utilities.SlicingInteractivity;
                si.Slicer(hfig);
            end





        end
    elseif nargout==1
        varargout{1}=meshinfo(obj);



    else
        error(message('antenna:antennaerrors:IncorrectNumArguments','output',...
        'output','1'));
    end

end

function warningNoMesh(obj)
    if isa(obj,'rfpcb.PrintedLine')||isa(obj,'pcbComponent')
        outstr=sprintf('<a href="matlab:help %s">%s</a>','rfpcb',...
        'help rfpcb');
        warning(message('rfpcb:rfpcberrors:NoMesh',outstr));
    else
        outstr=sprintf('<a href="matlab:help %s">%s</a>','antenna',...
        'help antenna');
        warning(message('antenna:antennaerrors:NoMesh',outstr));
    end
end