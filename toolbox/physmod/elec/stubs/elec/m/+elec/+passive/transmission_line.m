function elementSchema=transmission_line(~)






    elementSchema=ee.passive.lines.transmission_line();

    pm_warning('physmod:ee:library:DeprecatedClass','elec.passive.transmission_line','ee.passive.lines.transmission_line')

end