function[api,params]=checkPluginClass(className,~)




    if~exist(className,'class')
        error(message('audio:plugin:NotAClass'));
    end

    try

        mc=meta.class.fromName(className);
    catch me
        throw(me);
    end
    if isempty(mc)
        error(message('audio:plugin:NotAClass'));
    end

    apmc=meta.class.fromName('audioPlugin');
    if~(mc<apmc)
        error(message('audio:plugin:NotAnAudioPlugin'));
    end

    api=getAudioPluginInterface(mc);

    [params,api]=checkParameters(mc,api);
end

function api=getAudioPluginInterface(mc)
    mp=findPropertyNamed(mc,'PluginInterface');
    if isempty(mp)
        api=audioPluginInterface;
    else
        if~mp.Constant
            error(message('audio:plugin:InterfaceNotConst'));
        elseif~mp.HasDefault||isempty(mp.DefaultValue)
            error(message('audio:plugin:InterfaceNoValue'));
        elseif~isa(mp.DefaultValue,'audioPluginInterface')
            error(message('audio:plugin:InterfaceNotObject'));
        end
        api=mp.DefaultValue;
    end

    apsmc=meta.class.fromName('audioPluginSource');
    isSource=(mc<apsmc);

    if isSource
        if isempty(api.InputChannels)
            api.InputChannels=0;
        elseif~isequal(api.InputChannels,0)
            error(message('audio:plugin:SourceHasInputs'));
        end
    else
        if isempty(api.InputChannels)
            api.InputChannels=2;
        end
    end

    if isempty(api.OutputChannels)
        api.OutputChannels=2;
    end





    if isempty(api.PluginName)
        api.PluginName=mc.Name;
    end

    if isempty(api.UniqueId)
        api.UniqueId=char(audio.internal.str2uid(mc.Name));
    end

    if isempty(api.VendorName)
        api.VendorName='MathWorks';
    end

    if isempty(api.BundleIdentifier)
        bName=strrep(mc.Name,'_','-');
        uti=str2uti(api.VendorName);
        if~isempty(uti)
            api.BundleIdentifier=[uti,'.',bName];
        else
            api.BundleIdentifier=bName;
        end
    end

    if isempty(api.VendorCode)

        code=regexprep(api.VendorName,'[^A-Za-z]','');
        if numel(code)>=4
            code=code(1:4);
            if~any(isstrprop(code,'upper'))
                code(1)=upper(code(1));
            end
        else

            code=char(audio.internal.str2uid(api.VendorName));
        end
        api.VendorCode=code;
    end

end

function uti=str2uti(str)
    uti=regexprep(str,'\s+','-');
    uti=regexprep(uti,'[^-A-Za-z0-9.]','');
end

function[params,api]=checkParameters(mc,api)
    if isempty(api.Parameters)
        params=struct([]);
        return;
    end

    params=structfun(@(f)f,api.Parameters);
    for i=1:numel(params)
        mp=findPropertyNamed(mc,params(i).Property);
        if isempty(mp)
            error(message('audio:plugin:ParameterPropertyMissing',...
            mc.Name,params(i).Property,i));
        end
        checkParameterProperty(mp,params(i));

        defval=mp.DefaultValue;
        params(i).DefaultValue=defval;

        switch params(i).Law
        case 'lin'
            params(i).Shape=1;
        case 'log'
            params(i).Shape=0;
        case 'fader'
            params(i).Shape=3;
        case 'pow'
            params(i).Shape=params(i).Pow;
        case 'enum'
            nstrings=size(params(i).Enums,1);
            if isenum(defval)
                nenums=numel(enumeration(defval));
                if nstrings>nenums
                    error(message('audio:plugin:ParameterPropertyTooManyEnumsForEnumClass',...
                    params(i).Property,class(defval),nenums,nstrings));
                end
                params(i).Law='enumclass';
            elseif islogical(defval)
                if nstrings>2
                    error(message('audio:plugin:ParameterPropertyTooManyEnumsForLogical',...
                    params(i).Property,nstrings));
                end
                params(i).Law='logical';
            else
                assert(ischar(defval));
            end
        case 'int'
        otherwise
            assert(isempty(params(i).Law));

            if isa(defval,'double')

                assert(isempty(params(i).Min)&&isempty(params(i).Max));
                params(i).Law='lin';
                params(i).Min=0;
                params(i).Max=1;
                params(i).Shape=1;
            elseif isenum(defval)
                params(i).Law='enumclass';
                [~,names]=enumeration(defval);
                params(i).Enums=char(names);
            elseif islogical(defval)
                params(i).Law='logical';
                params(i).Enums=char({'off','on'});
            else
                assert(false);
            end
        end

        if isa(defval,'double')&&...
            ~(params(i).Min<=defval&&defval<=params(i).Max)
            error(message('audio:plugin:ParameterPropertyInitOutOfRange',params(i).Property));
        end

        [defaultStyle,validStyles]=law2styles(params(i).Law,numel(cellstr(params(i).Enums)));

        if isempty(params(i).Style)
            params(i).Style=defaultStyle;
        elseif~any(strcmpi(params(i).Style,validStyles))
            error(message('audio:plugin:ParameterBadStyle',...
            params(i).Style,params(i).Property,strjoin(validStyles,', ')));
        end

        if isempty(params(i).DisplayNameLocation)
            if strcmp(params(i).Style,'checkbox')
                params(i).DisplayNameLocation='none';
            else
                params(i).DisplayNameLocation='below';
            end
        end

        if~isempty(params(i).Layout)
            switch params(i).DisplayNameLocation
            case 'none'
                params(i).DisplayNameLayout=[];
                params(i).DisplayNameJustification='none';
            case 'left'
                c=params(i).Layout(1,2)-1;
                params(i).DisplayNameLayout=[params(i).Layout(:,1),[c;c]];
                params(i).DisplayNameJustification='right';
            case 'right'
                c=params(i).Layout(2,2)+1;
                params(i).DisplayNameLayout=[params(i).Layout(:,1),[c;c]];
                params(i).DisplayNameJustification='left';
            case 'above'
                r=params(i).Layout(1,1)-1;
                params(i).DisplayNameLayout=[[r;r],params(i).Layout(:,2)];
                params(i).DisplayNameJustification='below';
            case 'below'
                r=params(i).Layout(2,1)+1;
                params(i).DisplayNameLayout=[[r;r],params(i).Layout(:,2)];
                params(i).DisplayNameJustification='above';
            otherwise
                assert(false);
            end
        end

    end

    grid=api.GridLayout;
    if~isempty(grid)

        occupied=[];
        filmstripFrameSizeMap=containers.Map;

        for i=1:numel(params)
            p=params(i);
            prop=p.Property;

            if isempty(p.Layout)
                error(message("audio:plugin:ParameterNoLayout",prop));
            end

            if~isLayoutOnGrid(grid,p.Layout)
                error(message('audio:plugin:ParameterLayoutOffGrid',prop));
            end

            [yes,occupied]=isLayoutAvailableOnGrid(grid,p.Layout,occupied);
            if~yes
                error(message('audio:plugin:ParameterLayoutOverlap',prop));
            end

            if~isempty(p.DisplayNameLayout)
                if~isLayoutOnGrid(grid,p.DisplayNameLayout)
                    error(message('audio:plugin:ParameterDisplayNameLayoutOffGrid',prop));
                end

                [yes,occupied]=isLayoutAvailableOnGrid(grid,p.DisplayNameLayout,occupied);
                if~yes
                    error(message('audio:plugin:ParameterDisplayNameLayoutOverlap',prop));
                end
            end

            if~isempty(p.Filmstrip)
                strip=p.Filmstrip;
                frameSize=p.FilmstripFrameSize;
                if isKey(filmstripFrameSizeMap,strip)
                    prevSize=filmstripFrameSizeMap(strip);
                    if~isequal(prevSize,frameSize)
                        error(message('audio:plugin:InconsistentFrameSizes',...
                        strip,prevSize(1),prevSize(2),frameSize(1),frameSize(2)));
                    end
                else
                    info=imfinfo(strip);

                    validFormats={'png','GIF','jpg'};
                    if~any(strcmp(info.Format,validFormats))
                        error(message('audio:plugin:FilmstripUnsupportedFormat',...
                        strip,info.Format,strjoin(validFormats,', ')));
                    end

                    if info.Width==frameSize(1)

                        if mod(info.Height,frameSize(2))~=0
                            error(message('audio:plugin:InvalidVerticalFilmstrip',...
                            strip,info.Width,info.Height,frameSize(1),frameSize(2)));
                        end
                    elseif info.Height==frameSize(2)

                        if mod(info.Width,frameSize(1))~=0
                            error(message('audio:plugin:InvalidHorizontalFilmstrip',...
                            strip,info.Width,info.Height,frameSize(1),frameSize(2)));
                        end
                    else
                        error(message('audio:plugin:InvalidFrameSize',...
                        strip,info.Width,info.Height,frameSize(1),frameSize(2)));
                    end
                    filmstripFrameSizeMap(strip)=frameSize;
                end
            end

        end
    else

        f=figure('Visible','off');
        t=text(axes(f),'FontName','Noto','FontSize',15,'Units','Points');
        maxwid=0;
        for i=1:numel(params)
            t.String=params(i).DisplayName;
            maxwid=max(maxwid,t.Extent(3));
        end
        delete(f);
        maxwid=ceil(1.1*maxwid)+10;

        grid=audioPluginGridLayout(...
        'RowHeight',repmat(30,[1,numel(params)]),...
        'ColumnWidth',[maxwid,400],...
        'Padding',[10,10,10,30]);
        api.GridLayout=grid;

        for i=1:numel(params)
            params(i).Layout=[i,2;i,2];
            switch params(i).Law
            case{'enum','enumclass'}
                params(i).Style='dropdown';
            case 'logical'
                params(i).Style='checkbox';
            otherwise
                params(i).Style='hslider';
            end
            params(i).DisplayNameLocation='left';
            params(i).DisplayNameLayout=[i,1;i,1];
            params(i).DisplayNameJustification='right';
            params(i).EditBoxLocation='right';
        end
    end

end

function[defaultStyle,validStyles]=law2styles(law,nenums)
    switch law
    case{'lin','pow','log','fader','int'}
        defaultStyle='hslider';
        validStyles={'hslider','vslider','rotaryknob'};
    case{'enum','enumclass'}
        if nenums==2
            defaultStyle='vrocker';
            validStyles={'vrocker','vtoggle','dropdown'};
        else
            defaultStyle='dropdown';
            validStyles={'dropdown'};
        end
    case 'logical'
        defaultStyle='checkbox';
        validStyles={'checkbox','vrocker','vtoggle','dropdown'};
    otherwise
        assert(false);
    end
end

function checkParameterProperty(mp,param)

    if mp.Constant
        error(message('audio:plugin:ParameterPropertyConstant',mp.Name));
    elseif~(isequal(mp.SetAccess,'public')&&isequal(mp.GetAccess,'public'))
        error(message('audio:plugin:ParameterPropertyNotPublic',mp.Name));
    elseif~mp.HasDefault
        error(message('audio:plugin:ParameterPropertyUninitialized',mp.Name));
    end

    defval=mp.DefaultValue;

    if isempty(defval)
        error(message('audio:plugin:ParameterPropertyInitializedEmpty',mp.Name));
    elseif~(ischar(defval)||isscalar(defval))
        error(message('audio:plugin:ParameterPropertyNotScalar',mp.Name));
    elseif~isreal(defval)
        error(message('audio:plugin:ParameterPropertyNotReal',mp.Name));
    end


    if~(isa(defval,'double')||islogical(defval)||isenum(defval)||isString(defval))
        error(message('audio:plugin:ParameterPropertyNotValidClass',mp.Name,class(defval)));
    end


    if(isa(defval,'double')&&~any(strcmp(param.Law,{'','lin','fader','pow','log','int'})))...
        ||(islogical(defval)&&~any(strcmp(param.Law,{'','enum'})))...
        ||(isenum(defval)&&~any(strcmp(param.Law,{'','enum'})))...
        ||(isString(defval)&&~any(strcmp(param.Law,{'enum'})))
        error(message('audio:plugin:ParameterPropertyClassInvalidLaw',mp.Name,class(defval),param.Law));
    end

    if isString(defval)
        enums=cellstr(param.Enums);
        if~any(strcmp(defval,enums))
            error(message('audio:plugin:ParameterPropertyNotEnum',...
            mp.Name,sprintf(' ''%s''',enums{:})));
        end
    end
end

function mp=findPropertyNamed(mc,propertyName)
    if ischar(mc)
        mc=meta.class.fromName(mc);
    end
    allProps=mc.PropertyList;
    isP=arrayfun(@(mc)strcmp(mc.Name,propertyName),allProps);
    mp=allProps(isP);
    assert(numel(mp)<2);
end

function yes=isString(s)
    yes=ischar(s)&&isrow(s);
end

