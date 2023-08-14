

function[success,message]=checkoutLicense
    [success,message]=builtin('license','checkout','Simulink_Code_Inspector');
end