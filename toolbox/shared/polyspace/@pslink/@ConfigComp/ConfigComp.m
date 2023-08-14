

function this=ConfigComp(systemH)

    narginchk(0,1);
    if nargin<1
        systemH=[];
    else

        [meObj,systemH]=pssharedprivate('checkSystemValidity',systemH);
        if~isempty(meObj)
            systemH=[];
        end
    end

    this=pslink.ConfigComp;

    if~strcmp(this.Name,this.getName)
        this.Name=this.getName;
    end

    this.Description=[this.Name,' Custom Configuration Component'];

    this.restoreDefaults();

    if~isempty(get_param(systemH,'object'))
        this.PSSystemToAnalyze=get_param(systemH,'object').getFullName();
    end

    propsPsLinkCc=find(this.classhandle.properties,...
    'accessflags.publicset','on',...
    'accessflags.publicget','on',...
    'visible','on');
    listener(1)=handle.listener(this,propsPsLinkCc,'PropertyPostSet',@propertyChanged);
    listener(1).CallbackTarget=this;
    this.PSCompListener=listener;
    this.loadComponentDataModel;


