function gui=getSetTestGUI(obj)

    mlock;
    persistent TEST_GUI;
    if nargin>0
        TEST_GUI=obj;
    elseif~isempty(TEST_GUI)&&~isvalid(TEST_GUI)
        TEST_GUI=[];
    end
    gui=TEST_GUI;
end
