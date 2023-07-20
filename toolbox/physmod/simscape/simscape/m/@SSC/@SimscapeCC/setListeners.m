function setListeners(this)







    propList=getClientPropertyList;

    this.someListenersNotInstalled=false;

    for i=1:length(propList)

        prop=findprop(this,propList(i).Name);

        listenData=propList(i).Listener;

        for idx=1:numel(listenData)

            listener=handle.listener(this,prop,listenData(idx).Event{1},listenData(idx).Callback);
            listener.CallbackTarget=listenData(idx).CallbackTarget();

            if~isempty(listener.CallbackTarget)

                this.Listener=appendToList(this.Listener,listener);


            else


                this.someListenersNotInstalled=true;
                break;

            end

        end

    end





