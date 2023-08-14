function[tree,container]=uitree_deprecated(varargin)







    warn=warning('query','MATLAB:uitree:DeprecatedFunction');
    if isequal(warn.state,'on')
        warning(message('MATLAB:uitree:DeprecatedFunction'));
    end



    error(javachk('jvm'));
    nargoutchk(0,2);

    fig=[];
    numargs=nargin;

    if(nargin>0&&isscalar(varargin{1})&&ishandle(varargin{1}))
        if~ishghandle(handle(varargin{1}),'figure')
            error(message('MATLAB:uitree:InvalidFigureHandle'));
        end
        fig=varargin{1};
        varargin=varargin(2:end);
        numargs=numargs-1;
    end


    root=[];
    expfcn=[];
    selfcn=[];
    pos=[];


    if(numargs==1)
        error(message('MATLAB:uitree:InvalidNumInputs'));
    end

    for i=1:2:numargs-1
        if~ischar(varargin{i})
            error(message('MATLAB:uitree:UnrecognizedParameter'));

        end
        switch lower(varargin{i})
        case 'root'
            root=varargin{i+1};
        case 'expandfcn'
            expfcn=varargin{i+1};
        case 'selectionchangefcn'
            selfcn=varargin{i+1};
        case 'parent'
            if ishandle(varargin{i+1})
                f=varargin{i+1};
                if ishghandle(handle(f),'figure')
                    fig=f;
                end
            end
        case 'position'
            p=varargin{i+1};
            if isnumeric(p)&&(length(p)==4)
                pos=p;
            end
        otherwise
            error('MATLAB:uitree:UnknownParameter',['Unrecognized parameter: ',varargin{i}]);
        end
    end

    if isempty(expfcn)
        [root,expfcn]=processNode(root);
    else
        root=processNode(root);
    end




    tree_h=com.mathworks.hg.peer.UITreePeer;
    tree_h.setRoot(root);

    if isempty(fig)
        fig=gcf;
    end

    if isempty(pos)
        figpos=get(fig,'Position');
        pos=[0,0,min(figpos(3),200),figpos(4)];
    end

    [tree,container]=javacomponentfigurechild_helper(tree_h,pos,fig);

    if~isempty(expfcn)
        set(tree,'NodeExpandedCallback',{@nodeExpanded,tree,expfcn});
    end

    if~isempty(selfcn)
        set(tree,'NodeSelectedCallback',{@nodeSelected,tree,selfcn});
    end


    temp=handle.listener(tree,'ObjectBeingDestroyed',@componentDelete);
    save__listener__(tree,temp);

end


function componentDelete(src,evd)%#ok


    delete(handle(src.getFigureComponent()));
end


function nodeExpanded(src,evd,tree,expfcn)%#ok




    evdnode=evd.getCurrentNode;


    if~tree.isLoaded(evdnode)
        value=evdnode.getValue;


        cbk=expfcn;
        if iscell(cbk)
            childnodes=feval(cbk{1},tree,value,cbk{2:end});
        else
            childnodes=feval(cbk,tree,value);
        end

        if(length(childnodes)==1)

            chnodes=childnodes;
            childnodes=javaArray('com.mathworks.hg.peer.UITreeNode',1);
            childnodes(1)=java(chnodes);
        end

        tree.add(evdnode,childnodes);
        tree.setLoaded(evdnode,true);
    end

end


function nodeSelected(src,evd,tree,selfcn)%#ok
    cbk=selfcn;
    hgfeval(cbk,tree,evd);

end


function[node,expfcn]=processNode(root)
    expfcn=[];

    if isempty(root)||isa(root,'com.mathworks.hg.peer.UITreeNode')||...
        isa(root,'javahandle.com.mathworks.hg.peer.UITreeNode')
        node=root;
    elseif ishghandle(root)

        try





            node=matlab.ui.internal.uitreenode_deprecated(handle(root),get(root,'Type'),...
            [],isempty(get(0,'Children')));
        catch ex %#ok mlint
            node=[];
        end
        expfcn=@hgBrowser;
    elseif ismodel(root)





        try
            h=handle(get_param(root,'Handle'));



            node=matlab.ui.internal.uitreenode_deprecated(root,get(h,'Name'),...
            [],isempty(h.getHierarchicalChildren));
        catch ex %#ok mlint
            node=[];
        end
        expfcn=@mdlBrowser;
    elseif ischar(root)

        try
            iconpath=[matlabroot,'/toolbox/matlab/icons/foldericon.gif'];
            node=matlab.ui.internal.uitreenode_deprecated(root,root,iconpath,~isdir(root));
        catch ex %#ok mlint
            node=[];
        end
        expfcn=@dirBrowser;
    else
        node=[];
    end

end


function nodes=hgBrowser(tree,value)%#ok

    try
        count=0;
        parent=handle(value);
        ch=parent.Children;

        for i=1:length(ch)
            count=count+1;
            nodes(count)=matlab.ui.internal.uitreenode_deprecated(handle(ch(i)),get(ch(i),'Type'),[],...
            isempty(get(ch(i),'Children')));
        end
    catch ME %#ok<NASGU>
        error(message('MATLAB:uitree:UnknownNodeType'));
    end

    if(count==0)
        nodes=[];
    end

end


function nodes=mdlBrowser(tree,value)%#ok

    try
        count=0;
        parent=handle(get_param(value,'Handle'));
        ch=parent.getHierarchicalChildren;

        for i=1:length(ch)
            if~contains(class(ch(i)),'SubSystem')

            else

                count=count+1;
                descr=get(ch(i),'Name');
                isleaf=true;
                cch=ch(i).getHierarchicalChildren;
                if~isempty(cch)
                    for j=1:length(cch)
                        if contains(class(cch(j)),'SubSystem')
                            isleaf=false;
                            break;
                        end
                    end
                end
                nodes(count)=matlab.ui.internal.uitreenode_deprecated([value,'/',descr],descr,[],...
                isleaf);
            end
        end
    catch ME %#ok<NASGU>
        error(message('MATLAB:uitree:UnknownNodeType'));
    end

    if(count==0)
        nodes=[];
    end

end



function nodes=dirBrowser(tree,value)%#ok

    try
        count=0;
        ch=dir(value);

        for i=1:length(ch)
            if(any(strcmp(ch(i).name,{'.','..',''}))==0)
                count=count+1;
                if ch(i).isdir
                    iconpath=[matlabroot,'/toolbox/matlab/icons/foldericon.gif'];
                else
                    iconpath=[matlabroot,'/toolbox/matlab/icons/pageicon.gif'];
                end
                nodes(count)=matlab.ui.internal.uitreenode_deprecated([value,ch(i).name,filesep],...
                ch(i).name,iconpath,~ch(i).isdir);
            end
        end
    catch ME %#ok<NASGU>
        error(message('MATLAB:uitree:UnknownNodeType'));
    end

    if(count==0)
        nodes=[];
    end

end


function yesno=ismodel(input)
    yesno=false;

    try
        if is_simulink_loaded
            get_param(input,'handle');
            yesno=true;
        end
    catch ME %#ok<NASGU>

    end

end







function[hcomponent,hcontainer]=javacomponentfigurechild_helper(peer,position,parent)

    assert(isa(peer,'com.mathworks.hg.peer.FigureChild'));

    component=peer.getFigureComponent;
    [~,hcontainer]=matlab.ui.internal.JavaMigrationTools.suppressedJavaComponent(component,position,parent);
    hcomponent=handle(peer,'callbackproperties');






    setappdata(hcontainer,'JavaPeer',hcomponent);

    peer.setUIContainer(double(hcontainer));
end

function save__listener__(hC,hl)


    for i=1:numel(hC)
        p=findprop(hC(i),'Listeners__');
        if(isempty(p))
            p=schema.prop(hC(i),'Listeners__','handle vector');


            set(p,'AccessFlags.Serialize','off',...
            'AccessFlags.Copy','off',...
            'FactoryValue',[],'Visible','off');
        end

        hC(i).Listeners__=hC(i).Listeners__(ishandle(hC(i).Listeners__));
        hC(i).Listeners__=[hC(i).Listeners__;hl];
    end
end
