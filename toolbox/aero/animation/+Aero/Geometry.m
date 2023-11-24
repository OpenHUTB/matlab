classdef(CompatibleInexactProperties=true)Geometry...
    <matlab.mixin.SetGet&matlab.mixin.Copyable

    properties(Transient,SetObservable)
        Name='';
        Source='Auto';
        Reader=[];
        FaceVertexColorData=[];
    end

    methods
        function h=Geometry(varargin)
            if~builtin('license','test','Aerospace_Toolbox')
                error(message('aero:licensing:noLicenseGeom'));
            end

            if~builtin('license','checkout','Aerospace_Toolbox')
                return;
            end

        end

    end

    methods
        function set.Name(obj,value)


            obj.Name=value;
        end

        function set.Source(obj,value)

            value=check(Aero.AeroTypes.AeroGeometrySourceEnum,value,'Source');
            obj.Source=fcnSetSource(obj,value);
        end

        function set.Reader(obj,value)
            obj.Reader=fcnSetReader(obj,value);
        end

    end

    methods

        function read(h,src)

            h.FaceVertexColorData=[];
            h.Name='';

            if strcmp(h.Source,'Auto')



                if isa(src,'char')&&exist(src,'file')==2
                    [~,~,extension]=fileparts(src);
                    switch extension
                    case '.mat'
                        h.Source='MatFile';
                    case '.ac'
                        h.Source='Ac3d';
                    otherwise
                        error(message('aero:Geometry:NoAutoReadForThisExtension'));
                    end
                elseif isstruct(src)&&all(isfield(src,{'name','faces','vertices','cdata'}))
                    h.Source='Variable';
                else
                    error(message('aero:Geometry:NoAutoReadForThisExtension'));
                end

            end

            if strcmp(h.Source,'Custom')
                if isa(h.Reader,'function_handle')
                    if isempty(which(func2str(h.Reader)))
                        error(message('aero:Geometry:NoReadFcn'));
                    end
                else
                    error(message('aero:Geometry:NoFcnHandle'));
                end
            end

            [h.FaceVertexColorData,h.Name]=h.Reader(src,inputname(2));

        end

    end

end



function v=fcnSetReader(h,v)
    if~strcmp(h.Source,'Custom')&&~isa(v,'function_handle')
        error(message('aero:Geometry:setReader'));
    end

end

function v=fcnSetSource(h,v)


    switch v
    case 'Auto'
        h.Reader=[];
    case 'Variable'
        h.Reader=@ReadVariable;
    case 'MatFile'
        h.Reader=@ReadMatFile;
    case 'Ac3d'
        h.Reader=@ReadAc3dFile;
    case 'Custom'
    otherwise
        error(message('aero:Geometry:setSource'));
    end

end

function[data,name]=ReadAc3dFile(filename,varname)%#ok<INUSD>






















    [~,name,~]=fileparts(filename);
    [fid,emsg]=fopen(filename,'r');
    if fid==(-1)
        error(message('aero:Geometry:Ac3dFileOpenFailed',filename,emsg));
    end



    tline=fgetl(fid);
    kline=1;
    tok=lower(strtok(tline));
    if numel(tok)<4||~strncmpi(tok(1:4),'AC3D',4)
        fclose(fid);
        error(message('aero:Geometry:Ac3dBadFileFormat',filename));
    end


    [ac3dData,mats]=loadObject(fid,kline);
    fclose(fid);





    data=convertToPatchFormat(ac3dData,mats);
    if isempty(data)
        warning(message('aero:Geometry:Ac3dNoDataCreated',filename));
    end

end




function[newObj,mats,kline,prevkline]=loadObject(fid,kline)

    state='none';
    prevState='none';

    mats=[];
    newObj=[];

    prevkline=[];

    working=true;

    while working

        if working

            if~strmatch(state,'comment')
                prevState=state;
            end

            tline=fgetl(fid);
            if(~ischar(tline)&&~isstring(tline))||feof(fid)
                working=false;
                continue;
            else
                kline=kline+1;
            end
        end

        if isempty(tline)||tline(1)=='#'
            state='comment';
        else
            [tok,tline]=strtok(tline);%#ok<STTOK> % this is a re-do the first time through
            state=lower(tok);
        end
        try
            switch state
            case{'comment','none'}


            case 'material'


                toks=getTokens(tline);

                if numel(toks)==21

                    mat.name=toks{1}(2:end-1);

                    mat.rgb=[...
                    str2double(toks{3}),...
                    str2double(toks{4}),...
                    str2double(toks{5})];

                    mat.ambient=[...
                    str2double(toks{7}),...
                    str2double(toks{8}),...
                    str2double(toks{9})];

                    mat.emissive=[...
                    str2double(toks{11}),...
                    str2double(toks{12}),...
                    str2double(toks{13})];

                    mat.specular=[...
                    str2double(toks{15}),...
                    str2double(toks{16}),...
                    str2double(toks{17})];

                    mat.shininess=str2double(toks{19});

                    mat.transparency=str2double(toks{21});

                    if isempty(mats)
                        mats=mat;
                    else
                        mats(end+1)=mat;%#ok<AGROW>
                    end

                else
                    error(message('aero:Geometry:Ac3dCorruptMaterial',kline,filename));
                end

            case 'object'




                objType=sscanf(tline,'%s');
                newObj=initObject(objType);



                if~strmatch(prevState,{'kids','material'})
                    error(message('aero:Geometry:Ac3dMissingKids'));
                end



                switch objType
                case 'world'

                case 'group'

                case 'poly'

                case 'light'
                    warning(message('aero:Geometry:Ac3dLightNotSupported'));
                    return;
                end

            case 'kids'



                numKids=sscanf(tline,'%d');





                for k=1:numKids
                    [newObj.kids{k},~,kline,prevkline]=loadObject(fid,kline);
                end
                break;
            case 'name'
                tempName=sscanf(tline,'%s');
                newObj.name=tempName(2:(end-1));

            case 'loc'
                prevkline=kline;
                newObj.loc=reshape(sscanf(tline,'%f %f %f'),1,3);

            case 'numvert'
                numVert=sscanf(tline,'%d');
                prevkline=kline;
                [newObj.vertices,kline]=loadVertices(numVert,fid,kline);

            case 'numsurf'
                numSurf=sscanf(tline,'%d');
                for k=1:numSurf
                    prevkline=kline;
                    [newObj.surfaces(end+1),kline]=loadSurface(fid,kline);
                end

            case 'texture'
                tmpTextureFileName=sscanf(tline,'%s');
                newObj.texture=tmpTextureFileName(2:end-1);

            case 'texrep'
                prevkline=kline;
                newObj.textureRepeat=reshape(sscanf(tline,'%f %f'),1,2);

            case 'texoff'
                prevkline=kline;
                newObj.textureOffset=reshape(sscanf(tline,'%f %f'),1,2);

            case 'data'
                prevkline=kline;
                dataLen=sscanf(tline,'%d');
                newObj.data=fread(fid,dataLen,'*char');


            case 'rot'
                warning(message('aero:Geometry:Ac3drotNotSupported'));
            case 'url'
                warning(message('aero:Geometry:Ac3durlNotSupported'));
            case 'crease'
                newObj.creaseAngle=sscanf(tline,'%f');
                if isempty(newObj.creaseAngle)
                    error(message('aero:Geometry:Ac3dInvalidCrease',kline));
                end
            case 'creaseangle'
                newObj.creaseAngle=sscanf(tline,'%f');
                if isempty(newObj.creaseAngle)
                    error(message('aero:Geometry:Ac3dInvalidCreaseAngle',kline));
                end
            otherwise
                error(message('aero:Geometry:Ac3dUnknownKeyword',state,kline));
            end
        catch geomError




            if~isempty(fopen(fid))

                pos=ftell(fid);

                fseek(fid,0,'bof');

                lineCtr=0;


                while 1
                    fgetl(fid);
                    lineCtr=lineCtr+1;
                    cpos=ftell(fid);
                    if cpos>=pos
                        break
                    end
                end
                fclose(fid);
            end
            if~exist('lineCtr','var')
                lineCtr=prevkline;
            end


            lastwarn('');

            if~isempty(geomError)&&strncmpi('aero:Geometry',geomError.identifier,13)
                rethrow(geomError);
            else

                error(message('aero:Geometry:Ac3dCorruptFile',prevkline,lineCtr))
            end
        end
    end

end

function[vertSet,kline]=loadVertices(numVert,fid,kline)


    vertSet=[];

    for k=1:numVert
        dline=fgetl(fid);
        kline=kline+1;
        verts=sscanf(dline,'%f %f %f');





        if isempty(verts)
            error(message('aero:Geometry:Ac3dMissingVertices',kline-1));
        else
            vertSet=[vertSet;verts'];%#ok<AGROW>
        end
    end

end

function[surf,kline]=loadSurface(fid,kline)


    surf=initSurface();


    surfDefn=fgetl(fid);
    kline=kline+1;
    [surfStr,surfFlags]=strtok(surfDefn);
    if strcmp(surfStr,'SURF')&&~isempty(surfFlags)
        surf.flags=sscanf(surfFlags,'%x');
    else
        error(message('aero:Geometry:Ac3dCorruptSurfDef',filename,kline));
    end


    matDefn=fgetl(fid);
    kline=kline+1;
    [~,matVal]=strtok(matDefn);
    surf.mat=sscanf(matVal,'%d');


    refsDefn=fgetl(fid);
    kline=kline+1;
    [~,refsVal]=strtok(refsDefn);
    numRefs=sscanf(refsVal,'%d');
    if~isfinite(numRefs)||numRefs<0
        error(message('aero:Geometry:Ac3dCorruptRefDef',filename,kline));
    end


    for m=1:numRefs
        dline=fgetl(fid);
        kline=kline+1;
        sdata=sscanf(dline,'%d %f %f');
        surf.vertref(end+1)=sdata(1);
        surf.uvs=[surf.uvs;sdata(2:3)];
    end

end

function obj=initObject(thisType)


    obj.loc=[0,0,0];
    obj.name='';
    obj.data=[];
    obj.url='';
    obj.vertices=[];
    obj.surfaces=repmat(initSurface(),0,0);
    obj.texture=[];
    obj.texture_repeat=[];
    obj.texture_offset=[];
    obj.kids={};
    obj.matrix=eye(3);
    obj.type=thisType;

end

function s=initSurface()


    s.vertref=[];
    s.uvs=[];
    s.flags=0;
    s.mat=0;
    s.normal=[0,0,0];

end

function fv=flattenKids(fvin)


    fv=fvin;

    numKids=numel(fv);
    for m=1:numKids
        thisLoc=fv{m}.loc;
        if~isempty(fv{m}.kids)


            tmpKids=flattenKids(fv{m}.kids);


            for k=1:numel(tmpKids)
                numVerts=size(tmpKids{k}.vertices,1);
                if numVerts>0
                    tmpKids{k}.vertices=tmpKids{k}.vertices+repmat(thisLoc,numVerts,1);
                end
            end


            if~isempty(tmpKids)
                fv=[fv,tmpKids];%#ok<AGROW>
            end
        end
    end

end

function data=convertToPatchFormat(ac3dData,mats)


    fv=ac3dData.kids;
    data=[];



    fv=flattenKids(fv);



    dm=1;
    for m=1:numel(fv)
        if~isempty(fv{m}.surfaces)



            numFaces=numel(fv{m}.surfaces);
            faces=fv{m}.surfaces;
            maxCols=3;
            numCols=zeros(numFaces,1);
            for k=numFaces:(-1):1
                numCols(k)=size(faces(k).vertref,2);
                if numCols(k)>maxCols
                    maxCols=numCols(k);
                end
            end



            tmpFaces=NaN+zeros(numFaces,maxCols);
            for k=numFaces:(-1):1
                tmpFaces(k,1:numCols(k))=faces(k).vertref;
            end
            tmpFaces=tmpFaces+1;



            tmpVertices=fv{m}.vertices+...
            repmat(fv{m}.loc,size(fv{m}.vertices,1),1);






            tmpCData=zeros(numFaces,3);
            tmpAlphaData=zeros(numFaces,1);
            for k=1:numFaces
                tmpCData(k,:)=mats(faces(k).mat+1).rgb;
                tmpAlphaData(k,1)=1-mats(faces(k).mat+1).transparency;
            end



            data(dm).name=fv{m}.name;%#ok<AGROW>
            data(dm).faces=tmpFaces;%#ok<AGROW>
            data(dm).vertices=tmpVertices;%#ok<AGROW>
            data(dm).cdata=tmpCData;%#ok<AGROW>
            data(dm).alpha=tmpAlphaData;%#ok<AGROW>
            dm=dm+1;

        end
    end

end

function toks=getTokens(tline)


    notEnd=true;
    locLine=tline;
    toks={};

    while notEnd
        [toks{end+1},locLine]=strtok(locLine);%#ok<STTOK,AGROW>
        notEnd=~isempty(locLine);
    end

end

function[data,name]=ReadMatFile(filename,varname)%#ok


    allData=load(filename);
    if isstruct(allData)&&~isempty(allData)

        flds=fields(allData);
        data=allData.(flds{1});
        if~isstruct(data)||isempty(data)
            error(message('aero:Geometry:MatFileMustHaveGeomStruct'));
        end
        reqd={'name','vertices','faces','cdata'};
        for k=1:numel(reqd)
            if~isempty(strmatch('name',flds,'exact'))
                error(message('aero:Geometry:MatFileMustHaveGeomStruct'));
            end
        end
    else
        error(message('aero:Geometry:MatFileMustHaveGeomStruct'));
    end

    name=filename;

end

function[data,name]=ReadVariable(var,varname)


    data=var;
    name=varname;

end

