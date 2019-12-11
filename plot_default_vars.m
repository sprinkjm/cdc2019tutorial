function plot_default_vars(filename)
% this plots variables used in the default controller, which is intended to
% serve as a general velocity cruise controller for the vehicle
% plots the matlab file passed in
    load(filename);
%%
Time1 = min(cmd_vel.Time(1),min(cmd_vel_steering.Time(1),min(vel.Time(1),steering.Time(1))));

figure
hold on
plot(cmd_vel.Time-Time1,cmd_vel.Data,'--');
plot(vel.Time-Time1,vel.Data);
legend_entries = {'u','v'};

if( ~isempty(accel) )
    plot(accel.Time-Time1,accel.Data ./ 10.0);
    legend_entries{end+1} = 'accel * 0.1';
end


legend(legend_entries);
title(['Output relationships for ' filename]); 
xlabel('Time (s)')
ylabel('u (%), r (m/s)')

% figure
% hold on
% plot(cmd_angle.Time-Time1,cmd_angle.Data);
% plot(steering.Time-Time1,steering2angle(steering.Data));
% legend({'cmd\_angle','steering'});
end
