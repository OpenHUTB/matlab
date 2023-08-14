classdef ToolbarValidator<handle





    enumeration
restoreview
zoomout
zoomin
stepzoomout
stepzoomin
pan
rotate
datacursor
brush
export
saveas
copyimage
copyvector
default
none
    end

    methods(Static)

        function buttonPos=validateButtonArgs(buttonArgs,ax)
            [~,buttonTypesEnum]=enumeration('matlab.graphics.controls.internal.ToolbarValidator');



            buttonArgs=lower(buttonArgs);


            invalidTypeErr='MATLAB:graphics:axestoolbar:InvalidButtonType';
            invalidEnumErr='MATLAB:graphics:axestoolbar:InvalidButtonEnum';

            if~isempty(ax)&&(isa(ax,'matlab.graphics.axis.GeographicAxes')||isa(ax,'map.graphics.axis.MapAxes'))
                invalidTypeErr='MATLAB:graphics:axestoolbar:InvalidGeoButtonType';
                invalidEnumErr='MATLAB:graphics:axestoolbar:InvalidGeoButtonEnum';
            end



            buttonArgs=matlab.graphics.controls.internal.ToolbarValidator.findPartialMatch(buttonArgs,buttonTypesEnum,invalidTypeErr);

            [checkButtonParams,buttonPos]=ismember(buttonArgs,buttonTypesEnum);

            if~all(checkButtonParams)||...
                any(strcmpi(buttonArgs,matlab.graphics.controls.internal.ToolbarValidator.none))
                if iscell(buttonArgs)
                    error(message(invalidEnumErr));
                else
                    error(message(invalidTypeErr,string(buttonArgs)));
                end
            end

            if iscell(buttonArgs)
                for i=1:numel(buttonArgs)
                    btn=buttonArgs{i};

                    if~strcmpi(btn,matlab.graphics.controls.internal.ToolbarValidator.none)&&...
                        ~strcmpi(btn,matlab.graphics.controls.internal.ToolbarValidator.default)

                        if~matlab.graphics.controls.internal.ToolbarButtonRegistry.getInstance.isValidButtonForAxes(btn,ax)
                            error(message(invalidTypeErr,btn));
                        end
                    end
                end
            else

                if~strcmpi(buttonArgs,matlab.graphics.controls.internal.ToolbarValidator.none)&&...
                    ~strcmpi(buttonArgs,matlab.graphics.controls.internal.ToolbarValidator.default)

                    if~matlab.graphics.controls.internal.ToolbarButtonRegistry.getInstance.isValidButtonForAxes(buttonArgs,ax)
                        error(message(invalidTypeErr,string(buttonArgs)));
                    end
                end
            end
        end


        function isValid=isValidIcon(iconArgs)
            [~,iconTypesEnum]=enumeration('matlab.graphics.controls.internal.ToolbarValidator');
            isValid=ismember(iconArgs,iconTypesEnum)&&...
            ~any(strcmpi(iconArgs,matlab.graphics.controls.internal.ToolbarValidator.default));
        end




        function buttons=findPartialMatch(args,buttonTypesEnum,errKey)
            if iscell(args)
                buttons=cell(length(args),1);
            else
                buttons=cell(1,1);
            end



            buttonTypesEnum=buttonTypesEnum(cellfun(@(x)~strcmpi(x,'none'),buttonTypesEnum));

            for i=1:numel(buttons)


                if iscell(args)
                    button=args{i};
                else
                    button=args;
                end


                index=cellfun(@(x)~isempty(x),strfind(buttonTypesEnum,button));


                matches=buttonTypesEnum(index);

                for j=1:numel(matches)


                    if strncmpi(button,matches{j},strlength(button))
                        if isempty(buttons{i})
                            buttons{i}=matches{j};
                        else

                            ambiguousInputErr="MATLAB:graphics:axestoolbar:AmbiguousInput";
                            error(message(ambiguousInputErr,button));
                        end
                    end
                end



                if isempty(buttons{i})
                    error(message(errKey,button));
                end
            end
        end
    end
end