function [tempo, dev] = fit_tempo(pos)

dpos = diff(pos);
% dev = std(dpos);
dev = max(dpos) - min(dpos);
while true
    cont = false;
    for i = 1:numel(dpos)
%         i
        dpos_new = dpos;
        %dpos_new = [dpos_new(1:i-1) (dpos_new(i) / 2) (dpos_new(i) / 2) dpos_new(i+1:end)];
        dpos_new(i) = dpos_new(i) / 2;
        %dev_new = std(dpos_new); %take long time with unknow reason
        dev_new = max(dpos_new) - min(dpos_new);

        if dev_new < dev
            dev = dev_new;
            dpos = dpos_new;
            cont = true;
            break;
        end
    end
    if ~cont, break; end
end
% 
% dpos = diff(pos);
% dev = std(dpos);
% while true
%     index = find(dpos == max(dpos));
%     new_dpos = dpos;
%     new_dpos = [new_dpos(1:index-1) (new_dpos(index)/2) (new_dpos(index)/2) (new_dpos(index+1 :end))];
%     new_dev = std(new_dpos);
% 
%      if isempty(new_dev) && isempty(dev)
%        break;
%      end
%               
%     if (abs(new_dev) < dev)
%         dev = new_dev;
%         dpos = new_dpos;
%     else
%         break;
%     end
% end



tempo = median(dpos);

