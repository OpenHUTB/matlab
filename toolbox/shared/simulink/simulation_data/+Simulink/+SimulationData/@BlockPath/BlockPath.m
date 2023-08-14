
















































classdef BlockPath


    properties(Dependent=true,Access=public)

        SubPath;
        isLoadingModel;
        isSavingModel;

    end


    methods


        function obj=BlockPath(bpath,sub_path)
            if nargin>0&&isstring(bpath)
                bpath=cellstr(bpath);
            end
            if nargin>1&&isstring(sub_path)
                sub_path=char(sub_path);
            end


            if(nargin==0)
                obj.path={};


            elseif(isa(bpath,'Simulink.SimulationData.BlockPath')&&...
                length(bpath)==1)
                obj.path=bpath.path;
                obj.sub_path=bpath.sub_path;
                obj.ssid=bpath.ssid;


            elseif(iscellstr(bpath))
                if isempty(bpath)
                    obj.path={};
                elseif~ismatrix(bpath)
                    Simulink.SimulationData.utError('InvalidBlockPathParamsDims');
                else
                    sz=size(bpath);
                    if sz(1)==1
                        obj.path=Simulink.SimulationData.BlockPath.manglePath(bpath);
                    elseif sz(2)==1

                        obj.path=Simulink.SimulationData.BlockPath.manglePath(bpath');
                    else
                        Simulink.SimulationData.utError('InvalidBlockPathParamsDims');
                    end
                end


            elseif ischar(bpath)||isstring(bpath)

                obj.path={Simulink.SimulationData.BlockPath.manglePath(char(bpath))};



            else
                Simulink.SimulationData.utError('InvalidBlockPathParams');
            end



            if nargin>1&&~isempty(sub_path)
                if~ischar(sub_path)&&~isstring(sub_path)
                    Simulink.SimulationData.utError('BPathInvalidSubPath');
                end
                obj.sub_path=char(sub_path);
            end

        end


        function this=set.SubPath(this,val)
            if~ischar(val)&&~isstring(val)
                Simulink.SimulationData.utError('BPathInvalidSubPath');
            end
            this.sub_path=char(val);



            this=this.cacheSSIDs(false);
        end

        function val=get.SubPath(this)
            val=this.sub_path;
        end






        function this=set.isSavingModel(this,val)
            placeholder='$bdroot';
            if val



                this=this.updateTopModelName(bdroot,placeholder);
            else


                this=this.updateTopModelName(placeholder,bdroot);
            end
        end





        function this=set.isLoadingModel(this,val)
            if~val


                this=this.updateTopModelName('$bdroot',bdroot);
            end
        end


        function res=convertToCell(this)








            if length(this)~=1
                Simulink.SimulationData.utError('InvalidBlockPathArray');
            end



            res=this.path';
        end


        function res=getBlock(this,idx)











            if length(this)~=1
                Simulink.SimulationData.utError('InvalidBlockPathArray');
            end

            try
                res=this.path{idx};
            catch me %#ok<NASGU>
                Simulink.SimulationData.utError('InvalidBlockPathBlockIndex');
            end
        end


        function len=getLength(this)






            if length(this)~=1
                Simulink.SimulationData.utError('InvalidBlockPathArray');
            end

            len=length(this.path);
        end


        function res=isequal(this,rhs)





            if isstring(rhs)
                rhs=cellstr(rhs);
            end

            if(isa(rhs,'Simulink.SimulationData.BlockPath'))


                numEls=length(this);


                if numEls~=length(rhs)
                    res=false;


                elseif numEls>1
                    for idx=1:numEls
                        if~isequal(this(idx),rhs(idx))
                            res=false;
                            return;
                        end
                    end
                    res=true;


                elseif numEls==1
                    res=isequal(this.path,rhs.path)&&...
                    strcmp(this.sub_path,rhs.sub_path);

                elseif numEls==0
                    res=true;
                end

            elseif(iscellstr(rhs))



                if length(this)~=1
                    res=false;
                    return;
                end


                if~isempty(this.sub_path)
                    res=false;
                    return;
                end



                sizes=size(rhs);
                if(sizes(2)==1)
                    rhs=rhs';
                end

                res=isequal(this.path,...
                Simulink.SimulationData.BlockPath.manglePath(rhs));
            elseif ischar(rhs)&&length(this)==1



                if~isempty(this.sub_path)
                    res=false;
                    return;
                end

                res=isequal(this.path,...
                Simulink.SimulationData.BlockPath.manglePath({rhs}));
            else

                res=false;
            end
        end


        function res=isequaln(this,rhs)





            if isstring(rhs)
                rhs=cellstr(rhs);
            end

            if(isa(rhs,'Simulink.SimulationData.BlockPath'))


                numEls=length(this);


                if numEls~=length(rhs)
                    res=false;


                elseif numEls>1
                    for idx=1:numEls
                        if~isequaln(this(idx),rhs(idx))
                            res=false;
                            return;
                        end
                    end
                    res=true;


                elseif numEls==1
                    res=isequaln(this.path,rhs.path)&&...
                    strcmp(this.sub_path,rhs.sub_path);

                elseif numEls==0
                    res=true;
                end

            elseif(iscellstr(rhs))



                if length(this)~=1
                    res=false;
                    return;
                end


                if~isempty(this.sub_path)
                    res=false;
                    return;
                end



                sizes=size(rhs);
                if(sizes(2)==1)
                    rhs=rhs';
                end

                res=isequaln(this.path,...
                Simulink.SimulationData.BlockPath.manglePath(rhs));
            elseif ischar(rhs)&&length(this)==1



                if~isempty(this.sub_path)
                    res=false;
                    return;
                end

                res=isequaln(this.path,...
                Simulink.SimulationData.BlockPath.manglePath({rhs}));
            else

                res=false;
            end
        end

    end


    methods(Hidden=true)


        function disp(this,bPathOnly)



            if length(this)~=1
                Simulink.SimulationData.utNonScalarDisp(this);
                return;
            end

            if nargin<2||~bPathOnly

                mc=metaclass(this);
                if feature('hotlinks')
                    fprintf('  <a href="matlab: helpPopup %s">%s</a>\n',mc.Name,mc.Name);
                else
                    fprintf('  %s\n',mc.Name);
                end


                fprintf('  Package: %s\n\n',mc.ContainingPackage.Name);

                mObj=message('SimulationData:Objects:BlockPathPathHeading');
                fprintf('  %s\n',mObj.getString);
            end


            if isempty(this.path)
                fprintf('    ''''\n');
            else
                for idx=1:length(this.path)
                    this.displayPath(idx);
                end
            end


            if~isempty(this.sub_path)
                fprintf('\n  SubPath:\n    ''%s''\n',this.sub_path);
            end

            if nargin<2||~bPathOnly


                if feature('hotlinks')
                    mObj=message(...
                    'SimulationData:Objects:BlockPathPathHelp',...
                    class(this));
                    fprintf('\n  %s\n',mObj.getString);
                    fprintf('\n  <a href="matlab: methods(''%s'')">Methods</a>\n',mc.Name);
                else
                    mObj=message('SimulationData:Objects:BlockPathPathHelpNoLinks');
                    fprintf('\n  %s\n',mObj.getString);
                end
            else
                fprintf('\n');
            end

        end


        function displayPath(this,idx)



            indentStr=repmat('  ',1,idx);
            fprintf('  %s',indentStr);


            if feature('hotlinks')&&license('test','SIMULINK')







                path_str=this.path{idx};
                path_str=strrep(path_str,'''','''''');
                path_str=strrep(path_str,'"',''' char(34) ''');


                fprintf('<a href="matlab:Simulink.SimulationData.BlockPath.hilite_block([''%s''])">%s</a>\n',...
                path_str,this.path{idx});
            else
                fprintf('''%s''\n',this.path{idx});
            end

        end


        function this=updateTopModelName(this,origName,newName)
















            if length(this)~=1
                Simulink.SimulationData.utError('InvalidBlockPathArray');
            end

            if getLength(this)>0
                this.path{1}=...
                Simulink.SimulationData.BlockPath.replaceModelName(...
                this.path{1},...
                origName,...
                newName);
                if~isempty(this.ssid)
                    n=numel(origName);
                    if strncmp(this.ssid{1},[origName,':'],n+1)
                        this.ssid{1}=[newName,this.ssid{1}(n+1:end)];
                    end
                end
            end
        end


        function res=pathIsLike(this,rhs)












            if~isa(rhs,'Simulink.SimulationData.BlockPath')||...
                length(this)~=1||length(rhs)~=1
                Simulink.SimulationData.utError('InvalidBlockPathPathLike');
            end


            if isempty(rhs.path)
                res=isempty(this.path);


            elseif length(this.path)<length(rhs.path)
                res=false;


            elseif~strcmp(this.sub_path,rhs.sub_path)
                res=false;


            else
                sizeDif=length(this.path)-length(rhs.path);
                compPath=this.path(1+sizeDif:end);
                res=isequal(compPath,rhs.path);
            end
        end


        function this=cacheSSIDs(this,bOpenMdl)%#ok<INUSD>



            this.ssid={};
        end


        function this=refreshFromSSIDcache(this,bOpenMdl)%#ok<INUSD>




        end




        function res=getLastPath(this)
            if~isempty(this.path)
                res=this.path{end};
            else
                res='';
            end
        end




        function[path,sub_path]=getAsCellArray(this)
            path=this.path;
            sub_path=this.sub_path;
        end

    end


    methods(Hidden=true,Static=true)


        function hilite_block(bpath)



            model=Simulink.SimulationData.BlockPath.getModelNameForPath(bpath);
            try

                load_system(model);


                bd=get_param(model,'Object');
                bd.hilite('off');


                hilite_system(bpath);
            catch me
                throwAsCaller(me);
            end

        end


        function res=manglePath(pathStr)




            if isstring(pathStr)
                pathStr=cellstr(pathStr);
            end
            assert(ischar(pathStr)||iscellstr(pathStr));
            res=strrep(pathStr,newline,' ');
        end


        function model=getModelNameForPath(blockpath)






            indexes=strfind(blockpath,'/');
            if(isempty(indexes))
                model=blockpath;
            else
                index=indexes(1);
                model=blockpath(1:(index-1));
            end
        end


        function str=replaceModelName(str,origName,newName)






            curName=...
            Simulink.SimulationData.BlockPath.getModelNameForPath(str);

            if strcmp(curName,origName)
                newStart=length(origName)+1;
                oldLength=length(str);
                if newStart>oldLength
                    str=newName;
                else
                    blk=str(newStart:oldLength);
                    str=[newName,blk];
                end
            end
        end


        function this=loadobj(obj)





            this=obj;

            sizes=size(this.path);
            if(sizes(2)==1)
                this.path=this.path';
            end
        end


    end


    properties(Access='protected')

        path={};
        ssid={};
        sub_path='';
    end

end



