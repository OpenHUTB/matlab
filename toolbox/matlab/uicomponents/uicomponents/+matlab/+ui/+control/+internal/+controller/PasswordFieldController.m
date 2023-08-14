classdef(Hidden)PasswordFieldController<matlab.ui.control.internal.controller.ComponentController




    properties(Access=private)
        ChannelID='';
    end

    methods
        function obj=PasswordFieldController(varargin)
            obj@matlab.ui.control.internal.controller.ComponentController(varargin{:});



            obj.ChannelID=convertStringsToChars(['/'+matlab.lang.internal.uuid()+'/PasswordField']);

            obj.Model.ChannelID=obj.ChannelID;


            matlab.ui.control.internal.controller.PasswordFieldController.subscribeToCallback(obj.ChannelID);
        end
    end

    methods(Access='protected')
        function propertyNames=getAdditionalPropertyNamesForView(obj)

            propertyNames=getAdditionalPropertyNamesForView@matlab.ui.control.internal.controller.ComponentController(obj);


            propertyNames=[propertyNames;{...
'ChannelID'...
            }];
        end

        function viewPvPairs=getPropertiesForView(obj,propertyNames)












            viewPvPairs={};


            viewPvPairs=[viewPvPairs,...
            getPropertiesForView@matlab.ui.control.internal.controller.ComponentController(obj,propertyNames),...
            ];



            import appdesservices.internal.util.ismemberForStringArrays;
            if(ismemberForStringArrays("ChannelID",propertyNames))
                viewPvPairs=[viewPvPairs,...
                {'ChannelID',obj.ChannelID}...
                ];
            end
        end

        function handleEvent(obj,src,event)

            handleEvent@matlab.ui.control.internal.controller.ComponentController(obj,src,event);

            if(strcmp(event.Data.Name,'PasswordEntered'))

                passwordEnteredEventData=matlab.ui.eventdata.PasswordEnteredData(event.Data.Token);


                obj.handleUserInteraction('PasswordEntered',...
                {'PasswordEntered',passwordEnteredEventData});
            end
        end
    end

    methods
        function delete(obj)

            matlab.ui.control.internal.controller.PasswordFieldController.unsubscribeToCallback(obj.ChannelID);
        end
    end


end