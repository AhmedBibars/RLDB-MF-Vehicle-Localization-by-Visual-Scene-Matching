function [LongestGap]=FindLongestGap(CorrectLocalization)
LongestGap=1;
Accumilator=0;
for i=1:size(CorrectLocalization,1)
    if CorrectLocalization(i,1)==0
        Accumilator=Accumilator+1;
    else
        LongestGap=max(LongestGap,Accumilator);
        Accumilator=0;
    end
end
