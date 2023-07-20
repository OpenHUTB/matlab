function destroy(obj,varargin)


    st=obj.studio;
    if(st.isvalid)
        c=st.getService('GLUE2:ActiveEditorChanged');
        c.unRegisterServiceCallback(obj.registerCallbackId);
    end