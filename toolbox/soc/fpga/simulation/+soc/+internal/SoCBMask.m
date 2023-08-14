classdef SoCBMask
    properties
top
maskcb
mcat
    end
    methods
        function obj=SoCBMask(blkPath,blkProgName,maskcb,mcat)
            obj.top=Simulink.Mask.create(blkPath);
            obj.maskcb=maskcb;
            obj.mcat=mcat;

            intro=message([obj.mcat,blkProgName,'Intro']);
            descr=message([obj.mcat,blkProgName,'Descr']);
            fullDescr=sprintf('%s\n\n%s\n',intro.getString(),descr.getString());

            obj.top.Initialization=[obj.maskcb,'(''MaskInitFcn'',gcbh);'];
            obj.top.SelfModifiable='on';
            obj.top.IconUnits='normalized';
            obj.top.Description=fullDescr;
            obj.top.Help=sprintf('eval(''soc.internal.helpview(''''%s'''')'')',['soc_',lower(blkProgName)]);
        end

        function varargout=mcall(obj,call,varargin)
            if nargout==0
                feval(call,obj.top,varargin{:});
            else
                [varargout{1:nargout}]=feval(call,obj.top,varargin{:});
            end
        end





        function dc=dcTabContainer(obj,where,name,dcopts)
            ptag='';
            dcdef={'Row','new','Enabled','on','Visible','on'};
            dc=obj.dcGeneric('tabcontainer',where,name,ptag,[dcdef,dcopts]);
        end
        function dc=dcTab(obj,where,name,dcopts)
            ptag='';
            dcdef={'Enabled','on','Visible','on','AlignPrompts','on'};
            dc=obj.dcGeneric('tab',where,name,ptag,[dcdef,dcopts]);
        end
        function dc=dcGroup(obj,where,name,dcopts)
            ptag='';
            dcdef={'Row','new','Enabled','on','Visible','on','AlignPrompts','on'};
            dc=obj.dcGeneric('group',where,name,ptag,[dcdef,dcopts]);
        end
        function dc=dcCollapsiblePanel(obj,where,name,dcopts)
            ptag='';
            dcdef={'Row','new','Enabled','on','Visible','on','Expand','off','AlignPrompts','on'};
            dc=obj.dcGeneric('collapsiblepanel',where,name,ptag,[dcdef,dcopts]);
        end

        function dc=dcText(obj,where,name,ptag,dcopts)
            dcdef={'WordWrap','on','Row','new','Enabled','on','Visible','on','HorizontalStretch','on'};
            dc=obj.dcGeneric('text',where,name,ptag,[dcdef,dcopts]);
        end
        function dc=dcLink(obj,where,name,ptag,dcopts)
            dcdef={'Row','new','Enabled','on','Visible','on','HorizontalStretch','on'};
            callback={'Callback',[obj.maskcb,'(''MaskLinkCb'',''',[name,ptag],''',gcbh);']};
            dc=obj.dcGeneric('hyperlink',where,name,ptag,[dcdef,callback,dcopts]);
        end
        function dc=dcButton(obj,where,name,ptag,dcopts)
            dcdef={'Row','new','Enabled','on','Visible','on','HorizontalStretch','on'};
            callback={'Callback',[obj.maskcb,'(''MaskLinkCb'',''',[name,ptag],''',gcbh);']};
            dc=obj.dcGeneric('pushbutton',where,name,ptag,[dcdef,callback,dcopts]);
        end






        function p=pEdit(obj,where,name,ptag,val,cb,popts,dcopts)
            poptsdef={'Evaluate','on','Tunable','off','NeverSave','off',...
            'Hidden','off','ReadOnly','off','Enabled','on',...
            'Visible','on','ShowTooltip','on','Alias',''};
            dcoptsdef={'PromptLocation','left','Row','new','HorizontalStretch','on'};

            p=obj.pGeneric('edit',where,name,ptag,val,cb,[poptsdef,popts],[dcoptsdef,dcopts]);
        end
        function p=pPopup(obj,where,name,ptag,val,cb,vals,popts,dcopts)
            poptsdef={'Evaluate','off','Tunable','off','NeverSave','off',...
            'Hidden','off','ReadOnly','off','Enabled','on',...
            'Visible','on','ShowTooltip','on','Alias',''};
            dcoptsdef={'PromptLocation','left','Row','new','HorizontalStretch','on'};

            p=obj.pGeneric('popup',where,name,ptag,val,cb,[poptsdef,{'TypeOptions',vals},popts],[dcoptsdef,dcopts]);
        end
        function p=pCheckbox(obj,where,name,ptag,val,cb,popts,dcopts)
            poptsdef={'Evaluate','off','Tunable','off','NeverSave','off',...
            'Hidden','off','ReadOnly','off','Enabled','on',...
            'Visible','on','ShowTooltip','on','Alias',''};
            dcoptsdef={'Row','new','HorizontalStretch','on'};

            p=obj.pGeneric('checkbox',where,name,ptag,val,cb,[poptsdef,popts],[dcoptsdef,dcopts]);
        end
        function p=pDataTypeStr(obj,where,name,ptag,val,cb,dtypePos,dtypeSupport,popts,dcopts)
            poptsdef={'Evaluate','on','Tunable','off','NeverSave','off',...
            'Hidden','off','ReadOnly','off','Enabled','on',...
            'Visible','on','ShowTooltip','on','Alias',''};
            dcoptsdef={'Row','new','HorizontalStretch','on'};

            type=['unidt({a=',num2str(dtypePos),'|||}',dtypeSupport,')'];
            p=obj.pGeneric(type,where,name,ptag,val,cb,[poptsdef,popts],[dcoptsdef,dcopts]);
        end

    end


    methods(Access=protected)
        function largs=getPrompt(obj,name)
            prompt=[obj.mcat,name,'PR'];
            if isempty(getString(message(prompt)))
                largs={};
            else
                largs={'Prompt',prompt};
            end
        end
        function largs=getTooltip(obj,name)
            tt=[obj.mcat,name,'TT'];
            if isempty(getString(message(tt)))
                largs={};
            else
                largs={'Tooltip',tt};
            end
        end


        function dc=dcGeneric(obj,type,where,name,ptag,dcopts)
            if ischar(where)&&strcmp(where,'top'),where=obj.top;end
            prompt=obj.getPrompt(name);
            tt=obj.getTooltip(name);

            locargs=[{'Type',type,'Name'},[name,ptag],prompt,tt];
            allargs=[locargs,dcopts];
            dc=where.addDialogControl(allargs{:});


            lastVisiIdx=find(strcmp('Visible',allargs),1,'last');
            dc.Visible=allargs{lastVisiIdx+1};
        end


        function p=pGeneric(obj,type,where,name,ptag,val,cb,popts,dcopts)
            if ischar(where)&&strcmp(where,'top')
                container={''};
            else
                container={'Container',where.Name};
            end
            if cb
                callback={'Callback',[obj.maskcb,'(''MaskParamCb'',''',[name,ptag],''',gcbh);']};
            else
                callback={};
            end
            prompt=obj.getPrompt(name);
            tt=obj.getTooltip(name);

            locpopts=[{'Type',type,'Name',[name,ptag]},container,callback,prompt];
            allpopts=[locpopts,popts];
            p=obj.top.addParameter(allpopts{:});

            p.Value=val;

            dc=obj.top.getDialogControl([name,ptag]);
            if isempty(tt),tt={'Tooltip',''};end
            dcopts=[tt,dcopts];
            for ii=1:2:length(dcopts)
                dc.(dcopts{ii})=dcopts{ii+1};
            end
        end
    end


end
