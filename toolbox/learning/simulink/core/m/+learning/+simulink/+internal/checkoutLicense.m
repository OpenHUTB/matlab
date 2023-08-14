

function[licensesAreCheckedOut,uncheckedOutLicenses]=checkoutLicense(courseCode)



    uncheckedOutLicenses={};
    requiredProducts=learning.simulink.preferences.slacademyprefs.CourseMap(courseCode).ProductNames;
    numberOfProducts=length(requiredProducts);
    licensesArray=zeros(numberOfProducts,1);
    for i=1:numberOfProducts
        licenseName=learning.simulink.preferences.slacademyprefs.prodLicMap(requiredProducts{i});
        licensesArray(i)=license('checkout',licenseName);
        if~licensesArray(i)
            uncheckedOutLicenses{end+1}=requiredProducts{i};
        end
    end
    licensesAreCheckedOut=licensesArray;
end

