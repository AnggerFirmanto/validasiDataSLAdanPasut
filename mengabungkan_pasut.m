% %% MENGGABUNGKAN DATA PASANG SURUT
% % Definisikan nama file untuk data setiap tahun dari 2015 hingga 2023
% files = {'Tide_Corrected_Data_2015.csv', 'Tide_Corrected_Data_2016.csv', ...
%          'Tide_Corrected_Data_2017.csv', 'Tide_Corrected_Data_2018.csv', ...
%          'Tide_Corrected_Data_2019.csv', 'Tide_Corrected_Data_2020.csv', ...
%          'Tide_Corrected_Data_2021.csv', 'Tide_Corrected_Data_2022.csv', ...
%          'Tide_Corrected_Data_2023.csv',};
% 
% % Inisialisasi tabel kosong untuk menyimpan data gabungan
% dataGabungan = table();
% 
% % Loop melalui setiap file dan membaca data, kemudian tambahkan ke tabel data gabungan
% for i = 1:length(files)
%     % Baca data dari file CSV saat ini
%     dataSaatIni = readtable(files{i});
%     
%     % Memeriksa tipe data kolom Corrected_Tide dan mengkonversinya ke numerik jika perlu
%     if iscell(dataSaatIni.Corrected_Tide)
%         % Konversi cell array ke numerik
%         dataSaatIni.Corrected_Tide = str2double(dataSaatIni.Corrected_Tide);
%     end
%     
%     % Tambahkan data saat ini ke tabel data gabungan
%     dataGabungan = [dataGabungan; dataSaatIni];
% end
% 
% % Definisikan nama file untuk data gabungan CSV
% namaFileOutput = 'Data_Pasang_Surut_2015_2023.csv';
% 
% % Simpan tabel data gabungan ke file CSV
% writetable(dataGabungan, namaFileOutput);
% 
% % Tampilkan pesan yang menunjukkan bahwa proses selesai
% disp(['Data gabungan disimpan ke ', namaFileOutput]);
% 
% % Membaca data pasang surut dari file CSV
% dataPasangSurut = readtable('Data_Pasang_Surut_2015_2023.csv');
% 
% % Memeriksa tipe data kolom Corrected_Tide
% if ~isnumeric(dataPasangSurut.Corrected_Tide)
%     % Konversi ke numerik
%     dataPasangSurut.Corrected_Tide = str2double(dataPasangSurut.Corrected_Tide);
% end
% 
% % Menghapus baris dengan nilai NaN di kolom Corrected_Tide
% dataPasangSurut = rmmissing(dataPasangSurut, 'DataVariables', {'Corrected_Tide'});
% 
% % Mengubah satuan ketinggian dari centimeter ke meter
% dataPasangSurut.Corrected_Tide_m = dataPasangSurut.Corrected_Tide / 100;
% 
% % Menambahkan kolom bulan dan tahun
% dataPasangSurut.Bulan = month(dataPasangSurut.Datetime);
% dataPasangSurut.Tahun = year(dataPasangSurut.Datetime);
% 
% % Mengelompokkan data berdasarkan bulan dan tahun, lalu menghitung rata-rata ketinggian per bulan
% dataBulanan = varfun(@mean, dataPasangSurut, 'InputVariables', 'Corrected_Tide_m', ...
%                      'GroupingVariables', {'Tahun', 'Bulan'});
% 
% % Mengubah nama kolom hasil rata-rata
% dataBulanan.Properties.VariableNames{'GroupCount'} = 'JumlahData';
% dataBulanan.Properties.VariableNames{'mean_Corrected_Tide_m'} = 'RataRata_Corrected_Tide_m';
% 
% % Definisikan nama file untuk data bulanan CSV
% namaFileOutputBulanan = 'Data_Pasang_Surut_Bulanan_2015_2023.csv';
% 
% % Simpan tabel data bulanan ke file CSV
% writetable(dataBulanan, namaFileOutputBulanan);
% 
% % Tampilkan pesan yang menunjukkan bahwa proses selesai
% disp(['Data bulanan disimpan ke ', namaFileOutputBulanan]);


%% -------------------------------------------------------------------------------------------------------------------------------------------
% % PLOT BULET 
% % Read the monthly tidal data (2020-2023)
% pasang_surut_file = 'Data_Pasang_Surut_Bulanan_2020_2023.csv';
% pasang_surut_data = readtable(pasang_surut_file);
% 
% % Read the monthly SLA data (1993-2023)
% sla_file = 'SLA_1993_2023 bulanan.csv';
% sla_data = readtable(sla_file);
% 
% % Combine year and month columns into a datetime array for pasang surut data
% pasang_surut_time = datetime(pasang_surut_data.Tahun, pasang_surut_data.Bulan, ones(height(pasang_surut_data), 1));
% pasang_surut_values = pasang_surut_data.RataRata_Corrected_Tide_m;
% 
% % Convert SLA date strings to datetime and values to numeric
% sla_time = datetime(sla_data.Datetime, 'InputFormat', 'yyyy-MM-dd');
% sla_values = str2double(strrep(sla_data.SLA, ',', '.'));
% 
% % Merge datasets based on common dates
% [common_time, ia, ib] = intersect(pasang_surut_time, sla_time);
% common_pasang_surut_values = pasang_surut_values(ia);
% common_sla_values = sla_values(ib);
% 
% % Calculate RMSE between tide gauge and SLA data
% rmse_value = sqrt(mean((common_pasang_surut_values - common_sla_values).^2));
% 
% % Create a new figure
% figure;
% 
% % Plot the SLA data
% plot(sla_time, sla_values, 'o', 'MarkerEdgeColor', 'b');
% hold on;
% 
% % Plot the tidal data
% plot(pasang_surut_time, pasang_surut_values * 100, 'o', 'MarkerEdgeColor', 'r'); % Converted to cm
% 
% % Calculate and plot trend lines
% p_sla = polyfit(datenum(sla_time), sla_values, 1);
% p_pasang_surut = polyfit(datenum(pasang_surut_time), pasang_surut_values * 100, 1);
% 
% % Generate trend lines
% sla_trend = polyval(p_sla, datenum(sla_time));
% pasang_surut_trend = polyval(p_pasang_surut, datenum(pasang_surut_time));
% 
% % Plot trend lines
% plot(sla_time, sla_trend, 'Color', [0.4940 0.1840 0.5560], 'LineWidth', 2);
% plot(pasang_surut_time, pasang_surut_trend, 'Color', [0.6350 0.0780 0.1840], 'LineWidth', 2);
% 
% % Customizing the plot
% xlabel('Year');
% ylabel('Height (m)');
% title('Altimetry (6.4167°S, 105.7500°E) vs. Tide Gauge (Tanjung Lesung)');
% legend('Altimetry', 'Tide Gauge', 'Altimetry Trend', 'Tide Gauge Trend');
% grid on;
% 
% % Show the plot
% hold off;
% 
% % Display RMSE
% disp(['RMSE between tide gauge and SLA data: ', num2str(rmse_value), ' m']);

% %% --------------------------------------------------------------------------------------------------------------------------------------------------
% % File paths
% pasang_surut_file = 'Data_Pasang_Surut_Bulanan_2020_2023.csv';
% sla_file = 'SLA_1993_2023_kecil__.csv';
% 
% % Read the tide gauge data
% pasang_surut_data = readtable(pasang_surut_file);
% 
% % Read the SLA data
% sla_data = readtable(sla_file);
% 
% % Combine year and month into datetime array for tide gauge data
% pasang_surut_time = datetime(pasang_surut_data.Tahun, pasang_surut_data.Bulan, 1);
% pasang_surut_values = pasang_surut_data.RataRata_Corrected_Tide_m; % in meters
% 
% % Convert SLA dates to datetime and values to numeric
% sla_time = datetime(sla_data.Datetime, 'InputFormat', 'yyyy-MM-dd');
% sla_values = str2double(strrep(sla_data.SLA, ',', '.')); % in meters
% 
% % Create a new figure
% figure;
% 
% % Plot the SLA data
% yyaxis right;
% plot(sla_time, sla_values * 100, '-x', 'Color', [0.8500 0.3250 0.0980], 'DisplayName', 'SLA (cm)');
% ylabel('SLA (cm)');
% 
% % Hold on to add tidal data to the same plot
% hold on;
% 
% % Plot the tidal data
% yyaxis left;
% plot(pasang_surut_time, pasang_surut_values * 100, '-o', 'Color', [0 0.4470 0.7410], 'DisplayName', 'Tidal Data (cm)');
% ylabel('Tidal Data (cm)');
% 
% % Calculate and plot trend lines
% p_sla = polyfit(datenum(sla_time), sla_values * 100, 1);
% p_pasang_surut = polyfit(datenum(pasang_surut_time), pasang_surut_values * 100, 1);
% 
% % Generate trend lines
% sla_trend = polyval(p_sla, datenum(sla_time));
% pasang_surut_trend = polyval(p_pasang_surut, datenum(pasang_surut_time));
% 
% % Plot trend lines
% yyaxis right;
% plot(sla_time, sla_trend, '--', 'Color', [0.4940 0.1840 0.5560], 'LineWidth', 1.5, 'DisplayName', 'SLA Trend');
% 
% yyaxis left;
% plot(pasang_surut_time, pasang_surut_trend, '--', 'Color', [0.6350 0.0780 0.1840], 'LineWidth', 1.5, 'DisplayName', 'Tidal Data Trend');
% 
% % Customizing the plot
% xlabel('Year');
% title('Monthly Tidal Data and SLA (1993-2023)');
% legend('Location', 'northwest');
% grid on;
% 
% % Show the plot
% hold off;
% 
% % Display trend information in the command window
% disp(['SLA Trend (cm/year): ', num2str(p_sla(1)), ' cm/year']);
% disp(['Tidal Data Trend (cm/year): ', num2str(p_pasang_surut(1)), ' cm/year']);
% 
% % Calculate RMSE (if relevant to your data)
% % Uncomment the next line if you want to display RMSE and have it calculated
% % disp(['RMSE between tide gauge and SLA data: ', num2str(rmse_value), ' m']);

%% ------------------------------------------------------------------------------------------------------------------------------------------
% % File paths
% pasang_surut_file = 'Data_Pasang_Surut_Bulanan_2020_2023.csv';
% sla_file = 'SLA_1993_2023 bulanan.csv';
% 
% % Read the tide gauge data
% pasang_surut_data = readtable(pasang_surut_file);
% 
% % Read the SLA data
% sla_data = readtable(sla_file);
% 
% % Combine year and month into datetime array for tide gauge data
% pasang_surut_time = datetime(pasang_surut_data.Tahun, pasang_surut_data.Bulan, 1);
% pasang_surut_values = pasang_surut_data.RataRata_Corrected_Tide_m; % in meters
% 
% % Convert SLA dates to datetime and values to numeric
% sla_time = datetime(sla_data.Datetime, 'InputFormat', 'yyyy-MM-dd');
% sla_values = str2double(strrep(sla_data.SLA, ',', '.')); % in meters
% 
% % Interpolate pasang_surut_values to the same time points as sla_time
% common_pasang_surut_values = interp1(pasang_surut_time, pasang_surut_values, sla_time, 'linear');
% 
% % Remove NaN values that may result from interpolation
% valid_indices = ~isnan(common_pasang_surut_values) & ~isnan(sla_values);
% common_pasang_surut_values = common_pasang_surut_values(valid_indices);
% sla_values = sla_values(valid_indices);
% sla_time = sla_time(valid_indices);
% 
% % Create a new figure
% figure;
% 
% % Plot the SLA data
% yyaxis right;
% plot(sla_time, sla_values, '-x', 'Color', [0.8500 0.3250 0.0980], 'DisplayName', 'SLA (m)');
% ylabel('SLA (m)');
% 
% % Hold on to add tidal data to the same plot
% hold on;
% 
% % Plot the tidal data
% yyaxis left;
% plot(sla_time, common_pasang_surut_values, '-o', 'Color', [0 0.4470 0.7410], 'DisplayName', 'Tidal Data (m)');
% ylabel('Tidal Data (m)');
% 
% % Calculate and plot trend lines
% p_sla = polyfit(datenum(sla_time), sla_values, 1);
% p_pasang_surut = polyfit(datenum(sla_time), common_pasang_surut_values, 1);
% 
% % Generate trend lines
% sla_trend = polyval(p_sla, datenum(sla_time));
% pasang_surut_trend = polyval(p_pasang_surut, datenum(sla_time));
% 
% % Plot trend lines
% yyaxis right;
% plot(sla_time, sla_trend, '--', 'Color', [0.4940 0.1840 0.5560], 'LineWidth', 1.5, 'DisplayName', 'SLA Trend');
% 
% yyaxis left;
% plot(sla_time, pasang_surut_trend, '--', 'Color', [0.6350 0.0780 0.1840], 'LineWidth', 1.5, 'DisplayName', 'Tidal Data Trend');
% 
% % Customizing the plot
% xlabel('Year');
% title('Monthly Tidal Data and SLA (1993-2023)');
% legend('Location', 'northwest');
% grid on;
% 
% % Show the plot
% hold off;
% 
% % Calculate and display RMSE between tide gauge and SLA data
% rmse_value = sqrt(mean((sla_values - common_pasang_surut_values).^2));
% disp(['RMSE between tide gauge and SLA data: ', num2str(rmse_value), ' m']);
% 
% % Perform linear regression analysis
% regression_model = fitlm(common_pasang_surut_values, sla_values);
% 
% % Get R-square value
% r_square = regression_model.Rsquared.Ordinary;
% disp(['R-square value: ', num2str(r_square)]);
% 
% % Display regression results
% disp('Linear regression results:');
% disp(regression_model);

%% ----------------------------------------------------------------------------
% % File paths
% pasang_surut_file = 'Data_Pasang_Surut_Bulanan_2015_2023_edit.csv';
% sla_file = 'SLA_1993_2023_kecil__.csv';
% 
% % Read the tide gauge data
% opts = detectImportOptions(pasang_surut_file, 'Delimiter', ';');
% pasang_surut_data = readtable(pasang_surut_file, opts);
% 
% % Read the SLA data
% opts = detectImportOptions(sla_file, 'Delimiter', ';');
% sla_data = readtable(sla_file, opts);
% 
% % Convert date strings to datetime arrays
% pasang_surut_time = datetime(pasang_surut_data.Tahun, 'InputFormat', 'yyyy-MM-dd');
% pasang_surut_values = pasang_surut_data.RataRata_Corrected_Tide_m;
% 
% sla_time = datetime(sla_data.Datetime, 'InputFormat', 'yyyy-MM-dd');
% sla_values = sla_data.SLA;
% 
% % Handle NaN values
% valid_idx_sla = ~isnan(sla_values);
% valid_idx_pasang_surut = ~isnan(pasang_surut_values);
% 
% sla_time = sla_time(valid_idx_sla);
% sla_values = sla_values(valid_idx_sla);
% 
% pasang_surut_time = pasang_surut_time(valid_idx_pasang_surut);
% pasang_surut_values = pasang_surut_values(valid_idx_pasang_surut);
% 
% % Convert to centimeters
% sla_values_cm = sla_values * 100;
% pasang_surut_values_cm = pasang_surut_values * 100;
% 
% % Calculate linear correlation
% if length(sla_values_cm) == length(pasang_surut_values_cm)
%     correlation_coefficient = corr(sla_values_cm, pasang_surut_values_cm);
% else
%     warning('The lengths of SLA and tidal data do not match. Correlation calculation skipped.');
%     correlation_coefficient = NaN;
% end
% 
% % Plotting
% figure;
% 
% % SLA Data
% yyaxis right;
% plot(sla_time, sla_values_cm, '-x', 'Color', [0.8500 0.3250 0.0980], 'DisplayName', 'SLA (cm)');
% ylabel('SLA (cm)');
% 
% hold on;
% 
% % Tidal Data
% yyaxis left;
% plot(pasang_surut_time, pasang_surut_values_cm, '-o', 'Color', [0 0.4470 0.7410], 'DisplayName', 'Tidal Data (cm)');
% ylabel('Tidal Data (cm)');
% 
% % Trend Calculation
% days_per_year = 365.25;
% p_sla = polyfit(datenum(sla_time), sla_values_cm, 1);
% p_pasang_surut = polyfit(datenum(pasang_surut_time), pasang_surut_values_cm, 1);
% 
% sla_trend_per_year = p_sla(1) * days_per_year;
% pasang_surut_trend_per_year = p_pasang_surut(1) * days_per_year;
% 
% sla_trend = polyval(p_sla, datenum(sla_time));
% pasang_surut_trend = polyval(p_pasang_surut, datenum(pasang_surut_time));
% 
% % Plot Trend Lines
% yyaxis right;
% plot(sla_time, sla_trend, '--', 'Color', [0.4940 0.1840 0.5560], 'LineWidth', 1.5, 'DisplayName', 'SLA Trend');
% 
% yyaxis left;
% plot(pasang_surut_time, pasang_surut_trend, '--', 'Color', [0.6350 0.0780 0.1840], 'LineWidth', 1.5, 'DisplayName', 'Tidal Data Trend');
% 
% % Customization
% xlabel('Year');
% title('Monthly Tidal Data and SLA (1993-2023)');
% legend('Location', 'northwest');
% grid on;
% 
% hold off;
% 
% % Display trend and correlation
% disp(['SLA Trend (cm/year): ', num2str(sla_trend_per_year), ' cm/year']);
% disp(['Tidal Data Trend (cm/year): ', num2str(pasang_surut_trend_per_year), ' cm/year']);
% disp(['Correlation between SLA and Tidal Data: ', num2str(correlation_coefficient)]);

%%
% % Coba baca ulang file CSV dan tampilkan beberapa baris pertama
% try
%     sla_data = readtable('SLA_1993_2023_kecil__.csv');
%     disp('Beberapa baris pertama dari file SLA:');
%     disp(sla_data(1:5, :)); % Tampilkan 5 baris pertama
% catch ME
%     warning('Gagal membaca file CSV: %s', ME.message);
% end
% 
% % Asumsikan nama kolom di CSV adalah 'SLA'
% if ismember('SLA', sla_data.Properties.VariableNames)
%     sla_values_cm = sla_data.SLA;
% else
%     warning('Kolom SLA tidak ditemukan di file CSV.');
% end
% 
% if isempty(sla_values_cm)
%     warning('Data SLA kosong. Pastikan file CSV memiliki data yang benar.');
%     % Berikan penanganan alternatif atau keluarkan error
% end
% 
% % Ambil data SLA dari kolom kedua tabel
% sla_values_cm = sla_data.SLA;
% 
% % Pastikan data SLA tidak kosong
% if isempty(sla_values_cm)
%     warning('Data SLA kosong. Tidak ada data yang akan diolah.');
% else
%     disp('Beberapa nilai pertama dari SLA:');
%     disp(sla_values_cm(1:5)); % Tampilkan 5 nilai pertama SLA untuk verifikasi
% end
% % Misalnya, hitung rata-rata SLA
% sla_mean = mean(sla_values_cm);
% 
% % Tampilkan hasil
% disp(['Rata-rata SLA: ', num2str(sla_mean), ' cm']);
% % Periksa dan hapus nilai NaN
% sla_values_cm = sla_values_cm(~isnan(sla_values_cm));
% 
% % Jika masih ada nilai yang aneh, tampilkan peringatan
% if isempty(sla_values_cm)
%     warning('Data SLA tidak valid atau telah dibersihkan.');
% end
% 
% % Asumsikan data pasang surut telah disiapkan dalam 'pasang_surut_values_cm' dan 'pasang_surut_time'
% 
% % Plot data SLA dan Pasang Surut
% figure;
% 
% % Plot SLA
% yyaxis right;
% plot(sla_data.Datetime, sla_values_cm * 100, '-x', 'Color', [0.8500 0.3250 0.0980], 'DisplayName', 'SLA (cm)');
% ylabel('SLA (cm)');
% 
% % Tahan plot untuk menambahkan data pasang surut
% hold on;
% 
% % Plot Pasang Surut
% yyaxis left;
% plot(pasang_surut_time, pasang_surut_values_cm * 100, '-o', 'Color', [0 0.4470 0.7410], 'DisplayName', 'Pasang Surut (cm)');
% ylabel('Pasang Surut (cm)');
% 
% % Menampilkan legenda dan judul
% legend('Location', 'northwest');
% xlabel('Tahun');
% title('Data Pasang Surut dan SLA');
% grid on;
% % Pastikan panjang data sama sebelum menghitung korelasi
% if length(sla_values_cm) == length(pasang_surut_values_cm)
%     correlation_coefficient = corr(sla_values_cm, pasang_surut_values_cm);
%     disp(['Korelasi antara SLA dan Pasang Surut: ', num2str(correlation_coefficient)]);
% else
%     warning('Panjang data SLA dan Pasang Surut tidak sama. Korelasi tidak dapat dihitung.');
% end

%% -----------------------------------------------------------------------------------------------------------------
% % Data tren SLA dengan plot bhs inggris dan indo
% % File paths
% pasang_surut_file = 'Data_Pasang_Surut_Bulanan_2015_2023_edit.csv';
% sla_file = 'SLA_1993_2023_kecil__.csv';
% 
% % Read the tide gauge data
% opts = detectImportOptions(pasang_surut_file, 'Delimiter', ';');
% pasang_surut_data = readtable(pasang_surut_file, opts);
% 
% % Read the SLA data
% opts = detectImportOptions(sla_file, 'Delimiter', ';');
% sla_data = readtable(sla_file, opts);
% 
% % Convert date strings to datetime arrays
% pasang_surut_time = datetime(pasang_surut_data.Tahun, 'InputFormat', 'yyyy-MM-dd');
% pasang_surut_values = pasang_surut_data.RataRata_Corrected_Tide_m;
% 
% sla_time = datetime(sla_data.Datetime, 'InputFormat', 'yyyy-MM-dd');
% sla_values = sla_data.SLA;
% 
% % Handle NaN values
% valid_idx_sla = ~isnan(sla_values);
% valid_idx_pasang_surut = ~isnan(pasang_surut_values);
% 
% sla_time = sla_time(valid_idx_sla);
% sla_values = sla_values(valid_idx_sla);
% 
% pasang_surut_time = pasang_surut_time(valid_idx_pasang_surut);
% pasang_surut_values = pasang_surut_values(valid_idx_pasang_surut);
% 
% % Convert to centimeters
% sla_values_cm = sla_values * 100;
% pasang_surut_values_cm = pasang_surut_values * 100;
% 
% % Calculate linear correlation
% if length(sla_values_cm) == length(pasang_surut_values_cm)
%     correlation_coefficient = corr(sla_values_cm, pasang_surut_values_cm);
% else
%     warning('The lengths of SLA and tidal data do not match. Correlation calculation skipped.');
%     correlation_coefficient = NaN;
% end
% 
% % Plotting
% figure;
% 
% % SLA Data (Plot 1 - English)
% yyaxis right;
% plot(sla_time, sla_values_cm, '-x', 'Color', [0.8500 0.3250 0.0980], 'DisplayName', 'SLA (cm)');
% ylabel('SLA (cm)');
% 
% hold on;
% 
% % Tidal Data (Plot 1 - English)
% yyaxis left;
% plot(pasang_surut_time, pasang_surut_values_cm, '-o', 'Color', [0 0.4470 0.7410], 'DisplayName', 'Tidal Data (cm)');
% ylabel('Tidal Data (cm)');
% 
% % Trend Calculation for SLA only
% days_per_year = 365.25;
% p_sla = polyfit(datenum(sla_time), sla_values_cm, 1);
% sla_trend_per_year = p_sla(1) * days_per_year;
% sla_trend = polyval(p_sla, datenum(sla_time));
% 
% % Plot Trend Line for SLA only (Plot 1 - English)
% yyaxis right;
% plot(sla_time, sla_trend, '--', 'Color', [0.4940 0.1840 0.5560], 'LineWidth', 1.5, 'DisplayName', 'SLA Trend');
% 
% % Customization for Plot 1
% xlabel('Year');
% title('Monthly Tidal Data and SLA (1993-2023)');
% legend('Location', 'northwest');
% grid on;
% 
% % New Plot (Plot 2 - Bahasa Indonesia)
% figure;
% 
% % Data SLA dalam Bahasa Indonesia
% yyaxis right;
% plot(sla_time, sla_values_cm, '-x', 'Color', [0.8500 0.3250 0.0980], 'DisplayName', 'SLA (cm)');
% ylabel('SLA (cm)');
% 
% hold on;
% 
% % Data Pasang Surut dalam Bahasa Indonesia
% yyaxis left;
% plot(pasang_surut_time, pasang_surut_values_cm, '-o', 'Color', [0 0.4470 0.7410], 'DisplayName', 'Data Pasang Surut (cm)');
% ylabel('Data Pasang Surut (cm)');
% 
% % Plot Trend Line for SLA in Bahasa Indonesia
% yyaxis right;
% plot(sla_time, sla_trend, '--', 'Color', [0.4940 0.1840 0.5560], 'LineWidth', 1.5, 'DisplayName', 'Tren SLA');
% 
% % Customization for Plot 2
% xlabel('Tahun');
% title('Data Pasang Surut Bulanan dan SLA (1993-2023)');
% legend('Location', 'northwest');
% grid on;
% 
% hold off;
% 
% % Display SLA trend and correlation in English
% disp(['SLA Trend (cm/year): ', num2str(sla_trend_per_year), ' cm/year']);
% disp(['Correlation between SLA and Tidal Data: ', num2str(correlation_coefficient)]);
%% -----------------------------------------------------------------------------------------------------------------
% MENGHITUNG NILAI TREN PASANG SURUT DAN SLA 
% File paths
pasang_surut_file = 'Data_Pasang_Surut_Bulanan_2015_2023_edit.csv';
sla_file = 'SLA_1993_2023_kecil__.csv';

% Read the tide gauge data
opts = detectImportOptions(pasang_surut_file, 'Delimiter', ';');
pasang_surut_data = readtable(pasang_surut_file, opts);

% Read the SLA data
opts = detectImportOptions(sla_file, 'Delimiter', ';');
sla_data = readtable(sla_file, opts);

% Convert date strings to datetime arrays
pasang_surut_time = datetime(pasang_surut_data.Tahun, 'InputFormat', 'yyyy-MM-dd');
pasang_surut_values = pasang_surut_data.RataRata_Corrected_Tide_m;

sla_time = datetime(sla_data.Datetime, 'InputFormat', 'yyyy-MM-dd');
sla_values = sla_data.SLA;

% Handle NaN values
valid_idx_sla = ~isnan(sla_values);
valid_idx_pasang_surut = ~isnan(pasang_surut_values);

sla_time = sla_time(valid_idx_sla);
sla_values = sla_values(valid_idx_sla);

pasang_surut_time = pasang_surut_time(valid_idx_pasang_surut);
pasang_surut_values = pasang_surut_values(valid_idx_pasang_surut);

% Convert to centimeters
sla_values_cm = sla_values * 100;
pasang_surut_values_cm = pasang_surut_values * 100;

% Calculate linear correlation
if length(sla_values_cm) == length(pasang_surut_values_cm)
    correlation_coefficient = corr(sla_values_cm, pasang_surut_values_cm);
else
    warning('The lengths of SLA and tidal data do not match. Correlation calculation skipped.');
    correlation_coefficient = NaN;
end

% Calculate trend for SLA data
days_per_year = 365.25;
p_sla = polyfit(datenum(sla_time), sla_values_cm, 1);
sla_trend_per_year = p_sla(1) * days_per_year;
sla_trend = polyval(p_sla, datenum(sla_time));

% Calculate trend for Tidal data
p_pasang_surut = polyfit(datenum(pasang_surut_time), pasang_surut_values_cm, 1);
pasang_surut_trend_per_year = p_pasang_surut(1) * days_per_year;
pasang_surut_trend = polyval(p_pasang_surut, datenum(pasang_surut_time));

% Plotting
figure;

% SLA Data (Plot 1 - English)
yyaxis right;
plot(sla_time, sla_values_cm, '-x', 'Color', [0.8500 0.3250 0.0980], 'DisplayName', 'SLA (cm)');
ylabel('SLA (cm)');

hold on;

% Tidal Data (Plot 1 - English)
yyaxis left;
plot(pasang_surut_time, pasang_surut_values_cm, '-o', 'Color', [0 0.4470 0.7410], 'DisplayName', 'Tidal Data (cm)');
ylabel('Tidal Data (cm)');

% Plot Trend Line for SLA (Plot 1 - English)
yyaxis right;
plot(sla_time, sla_trend, '--', 'Color', [0.4940 0.1840 0.5560], 'LineWidth', 1.5, 'DisplayName', 'SLA Trend');

% Plot Trend Line for Tidal Data (Plot 1 - English)
yyaxis left;
plot(pasang_surut_time, pasang_surut_trend, '--', 'Color', [0.9290 0.6940 0.1250], 'LineWidth', 1.5, 'DisplayName', 'Tidal Trend');

% Customization for Plot 1
xlabel('Year');
title('Monthly Tidal Data and SLA (1993-2023)');
legend('Location', 'northwest');
grid on;

% New Plot (Plot 2 - Bahasa Indonesia)
figure;

% Data SLA dalam Bahasa Indonesia
yyaxis right;
plot(sla_time, sla_values_cm, '-x', 'Color', [0.8500 0.3250 0.0980], 'DisplayName', 'SLA (cm)');
ylabel('SLA (cm)');

hold on;

% Data Pasang Surut dalam Bahasa Indonesia
yyaxis left;
plot(pasang_surut_time, pasang_surut_values_cm, '-o', 'Color', [0 0.4470 0.7410], 'DisplayName', 'Data Pasang Surut (cm)');
ylabel('Data Pasang Surut (cm)');

% Plot Trend Line for SLA in Bahasa Indonesia
yyaxis right;
plot(sla_time, sla_trend, '--', 'Color', [0.4940 0.1840 0.5560], 'LineWidth', 1.5, 'DisplayName', 'Tren SLA');

% Plot Trend Line for Tidal Data in Bahasa Indonesia
yyaxis left;
plot(pasang_surut_time, pasang_surut_trend, '--', 'Color', [0.9290 0.6940 0.1250], 'LineWidth', 1.5, 'DisplayName', 'Tren Pasang Surut');

% Customization for Plot 2
xlabel('Tahun');
title('Data Pasang Surut Bulanan dan SLA (1993-2023)');
legend('Location', 'northwest');
grid on;

hold off;

% Display SLA trend, tidal trend, and correlation in English
disp(['SLA Trend (cm/year): ', num2str(sla_trend_per_year), ' cm/year']);
disp(['Tidal Trend (cm/year): ', num2str(pasang_surut_trend_per_year), ' cm/year']);
disp(['Correlation between SLA and Tidal Data: ', num2str(correlation_coefficient)]);

%% ------------------------------------------------------------------------------------------------------------
% % Data tren SLA dengan plot bhs inggris dan indo
% % File paths
% pasang_surut_file = 'Data_Pasang_Surut_Bulanan_2015_2023_edit.csv';
% sla_file = 'SLA_1993_2023_kecil__.csv';
% 
% % Read the tide gauge data
% opts = detectImportOptions(pasang_surut_file, 'Delimiter', ';');
% pasang_surut_data = readtable(pasang_surut_file, opts);
% 
% % Read the SLA data
% opts = detectImportOptions(sla_file, 'Delimiter', ';');
% sla_data = readtable(sla_file, opts);
% 
% % Convert date strings to datetime arrays
% pasang_surut_time = datetime(pasang_surut_data.Tahun, 'InputFormat', 'yyyy-MM-dd');
% pasang_surut_values = pasang_surut_data.RataRata_Corrected_Tide_m;
% 
% sla_time = datetime(sla_data.Datetime, 'InputFormat', 'yyyy-MM-dd');
% sla_values = sla_data.SLA;
% 
% % Handle NaN values
% valid_idx_sla = ~isnan(sla_values);
% valid_idx_pasang_surut = ~isnan(pasang_surut_values);
% 
% sla_time = sla_time(valid_idx_sla);
% sla_values = sla_values(valid_idx_sla);
% 
% pasang_surut_time = pasang_surut_time(valid_idx_pasang_surut);
% pasang_surut_values = pasang_surut_values(valid_idx_pasang_surut);
% 
% % Convert to centimeters
% sla_values_cm = sla_values * 100;
% pasang_surut_values_cm = pasang_surut_values * 100;
% 
% % Find the common dates between the two datasets
% [common_dates, ia, ib] = intersect(sla_time, pasang_surut_time);
% 
% % Extract the corresponding values for these common dates
% common_sla_values = sla_values_cm(ia);
% common_pasang_surut_values = pasang_surut_values_cm(ib);
% 
% % Calculate linear correlation for matched data
% if ~isempty(common_sla_values) && ~isempty(common_pasang_surut_values)
%     correlation_coefficient = corr(common_sla_values, common_pasang_surut_values);
%     disp(['Correlation between SLA and Tidal Data: ', num2str(correlation_coefficient)]);
% else
%     warning('No matching dates between SLA and tidal data. Correlation calculation skipped.');
%     correlation_coefficient = NaN;
% end
%% -----------------------------------------------------------------------------------------------------------
% % Menghitung kovarian antara SLA dan anomali pasang surut
% cov_matrix = cov(common_sla_values, common_pasang_surut_values);
% cov_sla_pasang_surut = cov_matrix(1,2);  % Mengambil nilai kovarian antar dua variabel
% 
% % Menghitung standar deviasi SLA dan anomali pasang surut
% std_sla = std(common_sla_values);
% std_pasang_surut = std(common_pasang_surut_values);
% 
% % Menghitung korelasi Pearson menggunakan rumus standar
% r_pearson = cov_sla_pasang_surut / (std_sla * std_pasang_surut);
% 
% % Menampilkan hasil korelasi Pearson
% disp(['Korelasi Pearson: ', num2str(r_pearson)]);

%% ----------------------------------
% % File paths
% pasang_surut_file = 'Data_Pasang_Surut_Bulanan_2015_2023_edit.csv';
% sla_file = 'SLA_1993_2023_kecil__.csv';
% 
% % Read the tide gauge data
% opts = detectImportOptions(pasang_surut_file, 'Delimiter', ';');
% pasang_surut_data = readtable(pasang_surut_file, opts);
% 
% % Read the SLA data
% opts = detectImportOptions(sla_file, 'Delimiter', ';');
% sla_data = readtable(sla_file, opts);
% 
% % Convert date strings to datetime arrays
% pasang_surut_time = datetime(pasang_surut_data.Tahun, 'InputFormat', 'yyyy-MM-dd');
% pasang_surut_values = pasang_surut_data.RataRata_Corrected_Tide_m;
% 
% sla_time = datetime(sla_data.Datetime, 'InputFormat', 'yyyy-MM-dd');
% sla_values = sla_data.SLA;
% 
% % Handle NaN values
% valid_idx_sla = ~isnan(sla_values);
% valid_idx_pasang_surut = ~isnan(pasang_surut_values);
% 
% sla_time = sla_time(valid_idx_sla);
% sla_values = sla_values(valid_idx_sla);
% 
% pasang_surut_time = pasang_surut_time(valid_idx_pasang_surut);
% pasang_surut_values = pasang_surut_values(valid_idx_pasang_surut);
% 
% % Convert to centimeters
% sla_values_cm = sla_values * 100;
% pasang_surut_values_cm = pasang_surut_values * 100;
% 
% % Find the common dates between the two datasets
% [common_dates, ia, ib] = intersect(sla_time, pasang_surut_time);
% 
% % Extract the corresponding values for these common dates
% common_sla_values = sla_values_cm(ia);
% common_pasang_surut_values = pasang_surut_values_cm(ib);
% 
% % Calculate linear correlation for matched data
% if ~isempty(common_sla_values) && ~isempty(common_pasang_surut_values)
%     % Mean of each variable
%     mean_sla = mean(common_sla_values);
%     mean_pasang_surut = mean(common_pasang_surut_values);
%     
%     % Deviations from the mean
%     dev_sla = common_sla_values - mean_sla;
%     dev_pasang_surut = common_pasang_surut_values - mean_pasang_surut;
%     
%     % Covariance
%     covariance = sum(dev_sla .* dev_pasang_surut) / (length(common_sla_values) - 1);
%     
%     % Standard deviations
%     std_sla = std(common_sla_values); % Standar deviasi dari SLA
%     std_pasang_surut = std(common_pasang_surut_values); % Standar deviasi dari Pasang Surut
%     
%     % Pearson Correlation Coefficient
%     correlation_coefficient = covariance / (std_sla * std_pasang_surut);
%     
%     % Display results
%     disp(['Covariance (SLA and Tidal Data): ', num2str(covariance)]);
%     disp(['Standard Deviation of SLA: ', num2str(std_sla)]);
%     disp(['Standard Deviation of Tidal Data: ', num2str(std_pasang_surut)]);
%     disp(['Correlation between SLA and Tidal Data: ', num2str(correlation_coefficient)]);
% else
%     warning('No matching dates between SLA and tidal data. Correlation calculation skipped.');
% end


