classdef renderingCallbackHandler

























    methods(Static)
        function handleCallback(index)
            [~,callbacks,testcases]=renderingCallbackHandler.setgetCallbackMap();
            testcase=testcases{index};
            callback=callbacks{index};

            if~isempty(callback)

                if isempty(testcase)
                    callback();

                else






                    if isvalid(testcase)
                        callback(testcase);
                    end
                end
            end
        end





















        function registerCallback(editor,funcPtr,testcase,callbackOnceFlag,noDisplay)
            SLM3I.SLCommonDomain.setWebBlockRenderingCallbackMode(true);
            if(nargin<5||~noDisplay)
                disp(['Registering webblocks-rendered callback: ',func2str(funcPtr),' for editor ',editor.getName()]);
            end
            if nargin==5
                renderingCallbackHandler.setgetCallbackMap(editor,funcPtr,testcase,callbackOnceFlag,noDisplay);
            elseif nargin==4
                renderingCallbackHandler.setgetCallbackMap(editor,funcPtr,testcase,callbackOnceFlag);
            elseif nargin==3



                if~isempty(which(func2str(funcPtr)))
                    if~ismethod(testcase,func2str(funcPtr))
                        warning('The provided callback function is not a method of the inputted testcase object. If you are intentionally using a callback from the MATLAB path, do not input the third argument (testcase) to registerCallback.');
                    end
                end
                renderingCallbackHandler.setgetCallbackMap(editor,funcPtr,testcase);
            elseif nargin==2
                renderingCallbackHandler.setgetCallbackMap(editor,funcPtr,[]);
            end
        end

        function deregisterCallback(editor)
            renderingCallbackHandler.setgetCallbackMap(editor);
        end

        function[eds,cbs,tcs]=setgetCallbackMap(editor,callbackFunc,testcase,callbackOnceFlag,noDisplay)


            persistent callbacks;
            persistent editors;
            persistent testcases;

            if isempty(callbacks)||isempty(editors)||isempty(testcases)
                callbacks={};
                editors={};
                testcases={};

                if(nargin<5||~noDisplay)


                    disp(' ');
                    disp('To avoid memory leaks using renderingCallbackHandler, execute the following cleanup command to clear persistent callback information when finished: ');
                    disp('renderingCallbackHandler.cleanup');
                    disp(' ');
                end
            end
            eds=[];
            cbs=[];
            tcs=[];


            if nargin>=3
                index=findIndexOfEditor(editor,editors);
                if isempty(index)
                    editors=[editors,{editor}];
                    callbacks=[callbacks,{callbackFunc}];
                    testcases=[testcases,{testcase}];
                    index=length(editors);

                else
                    editors{index}=editor;
                    callbacks{index}=callbackFunc;



                    testcases{index}=testcase;
                end
                if nargin==3
                    SLM3I.SLCommonDomain.registerAllWebBlocksRenderedCallback(editor,index,false);
                elseif nargin==4
                    SLM3I.SLCommonDomain.registerAllWebBlocksRenderedCallback(editor,index,callbackOnceFlag);
                end

            elseif nargin==1

                if ischar(editor)
                    if strcmp(editor,'clear')
                        callbacks={};
                        editors={};
                        testcases={};
                    end

                else
                    index=findIndexOfEditor(editor,editors);
                    if~isempty(index)
                        callbacks{index}=[];
                        editors{index}=[];


                        if sum(cellfun(@(c)~isempty(c),callbacks))==0
                            renderingCallbackHandler.cleanup;
                        end
                    end
                end

            elseif nargin==0
                eds=editors;
                cbs=callbacks;
                tcs=testcases;
            end
        end

        function cleanup()
            SLM3I.SLCommonDomain.clearEditorCallbackMaps();
            SLM3I.SLCommonDomain.setWebBlockRenderingCallbackMode(false);
            renderingCallbackHandler.setgetCallbackMap('clear');
        end
    end
end



function indices=findIndexOfEditor(ed,editors)
    indices=[];
    for i=1:length(editors)
        if(~isempty(editors{i})&&editors{i}==ed)
            indices=[indices,i];
        end
    end
end





