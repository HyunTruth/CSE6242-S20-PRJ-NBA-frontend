### stats.nba.com scraping ###

#region Imports
import pandas as pd
import numpy as np
from bs4 import BeautifulSoup
import requests
import datetime as dt
import os
import json
import time
from datetime import timedelta, date

#selenium imports
import selenium

from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.common.by import By
from selenium.common.exceptions import TimeoutException, NoSuchElementException
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support import expected_conditions as EC 
from selenium.webdriver.common.action_chains import ActionChains
#endregion


#region stats.nba.com scraper class
class nba_stats:
    def __init__(self,start_date,end_date, season,season_type = "Regular", date_list = None):

        self.start_date = start_date
        self.end_date = end_date
        self.season = season
        self.season_type = season_type
        self.date_list = date_list


    def daterange(self,start_date,end_date):
        for n in range(int ((end_date - start_date).days)):
            yield start_date + timedelta(n)

    def defensive_rebounding(self):
        """
        WIP - Contended DREB, DREB Chances, AVG DREB dist
        https://stats.nba.com/players/defensive-rebounding/
        """
        return None
    
    def play_type(self):
        """
        WIP - FG%/PPP by isolation, P&R (BH and RM), post-up, spot-up, handoff, 
        off-screen, putbacks
        https://stats.nba.com/players/isolation/
        """
        return None

    def defensive_dashboard(self, shot_category = 'overall'):
        """
        Similar to opponent shooting, but includes an expected FG% --> something we
        can't calculate - this might be more useful than opponent_shooting
        https://stats.nba.com/players/defense-dash-overall/
        """
        acceptable_categories = ['overall','3pt','2pt','lt6','lt10','gt15']
        if shot_category not in acceptable_categories:
            print("Please choose from one of these options for shot category:")
            return acceptable_categories

        df_all = pd.DataFrame(columns=['Player','Team','Age','Position','GP','G','DFGM',
                                        'DFGA','EFG%','DIFF%'])

        #Date Range Starting Loop
        if self.date_list == None:
            dates = [d for d in self.daterange(self.start_date, self.end_date)]
        else:
            dates = self.date_list
        for single_date in dates:
            url = 'https://stats.nba.com/players/defense-dash-'
            # incognito window
            chrome_options = Options()
            chrome_options.add_argument("--incognito")
            # open driver
            driver = webdriver.Chrome(r"C:/Users/Spelk/Documents/chromedriver_win32/chromedriver.exe")

            # date parameters
            year = single_date.strftime("%Y")
            month = single_date.strftime("%m")
            day = single_date.strftime("%d")
            full_date = single_date.strftime("%Y-%m-%d")

            # dynamic url one date at a time
            url += shot_category + "/"
            url += "?Season=" + str(self.season)
            url += "-" + str(self.season+1)[2:]
            url += "&SeasonType=" + self.season_type
            url += "%20Season&DateFrom=" + month
            url += "%2F" + day + "%2F" + year
            url += "&DateTo=" + month + "%2F" + day + "%2F" + year

            # go to url
            driver.get(url)
            time.sleep(15)

            print("Reached url for:",full_date,"... \n")
            #data with error handling
            try:
                stats_table = driver.find_element_by_class_name('nba-stat-table__overflow')
                stats_text = stats_table.text
                try:
                    driver.find_element_by_xpath("/html/body/main/div[2]/div/div[2]/div/div/nba-stat-table/div[1]/div/div/select/option['All']").click()
                except:
                    pass
            except: # No such element exception
                print("No games on this date - pass \n")
                driver.close()
                continue

            #Create df from text
            print("Now scraping the table \n")
            player = []
            team = []
            age = []
            pos = []
            gp = []
            g = []
            dfgm = []
            dfga = []
            efg = []
            dif = []

            for index,line in enumerate(stats_text.split('\n')[1:]): #first for is the header
                #get column names
                if index % 2 == 0:
                    [player.append(p) for p in [line]]
                else:
                    stats = line.split(' ')
                    team.append(stats[0])
                    age.append(stats[1])
                    pos.append(stats[2])
                    gp.append(stats[3])
                    g.append(stats[4])
                    dfgm.append(stats[6])
                    dfga.append(stats[7])
                    efg.append(stats[9])
                    dif.append(stats[10])

            #Create new_df and append to df_all
            new_df = pd.DataFrame({'Player':player,
                        'Team':team,
                        'Age':age,
                        'Position':pos,
                        'GP':gp,
                        'G':g,
                        'DFGM':dfgm,
                        'DFGA':dfga,
                        'EFG%':efg,
                        'DIFF%':dif})
            new_df['Game_Date'] = full_date
            df_all = df_all.append(new_df,ignore_index = True)
            print("Done scraping",full_date,"\n")
            driver.close()
            time.sleep(3)
        df_all['Shot_Category'] = shot_category
        return df_all

    def opponent_shooting(self):
        df_all = pd.DataFrame(columns=['Player','Team','Age','Distance','FGM','FGA','Game_Date'])
        
        #Date Range Starting Loop
        if self.date_list == None:
            dates = [d for d in self.daterange(self.start_date, self.end_date)]
        else:
            dates = self.date_list
        for single_date in dates:
            url = 'https://stats.nba.com/players/opponent-shooting/?Season='
            # incognito window
            chrome_options = Options()
            chrome_options.add_argument("--incognito")
            # open driver
            driver = webdriver.Chrome(r"C:/Users/Spelk/Documents/chromedriver_win32/chromedriver.exe")

            # date parameters
            year = single_date.strftime("%Y")
            month = single_date.strftime("%m")
            day = single_date.strftime("%d")
            full_date = single_date.strftime("%Y-%m-%d")

            # dynamic url one date at a time
            url += str(self.season)
            url += "-" + str(self.season+1)[2:]
            url += "&SeasonType=" + self.season_type
            url += "%20Season&DateFrom=" + month
            url += "%2F" + day + "%2F" + year
            url += "&DateTo=" + month + "%2F" + day + "%2F" + year

            # go to url
            driver.get(url)
            time.sleep(18) # ! Load time - come up with a better way for this and the following line (clicking all)

            #data with error handling
            try:
                stats_table = driver.find_element_by_class_name('nba-stat-table__overflow')
                stats_text = stats_table.text
                try:
                    driver.find_element_by_xpath("/html/body/main/div[2]/div/div[2]/div/div/nba-stat-table/div[1]/div/div/select/option['All']").click()
                except:
                    pass
            except: # No such element exception
                print("This date failed or there are no games on this date - pass \n")
                print(single_date)
                driver.close()
                continue

            print("Reached url for:",full_date,"... \n")

            print("Now scraping the table \n")
            #data
            stats_table = driver.find_element_by_class_name('nba-stat-table__overflow')
            stats_text = stats_table.text

            #Create df from text
            distances = ['0_5_ft','5_9_ft','10_14_ft','15_19_ft',
                '20_24_ft','25_29_ft']
            player = []
            team = []
            age = []
            distance = []
            fgm = []
            fga = []

            for index,line in enumerate(stats_text.split('\n')[2:]): #first two rows are headers
                #get column names
                if index % 2 == 0:
                    [player.append(p) for p in [line]*len(distances)]
                else:
                    stats = line.split(' ')
                    [team.append(i) for i in [stats[0]]*len(distances)]
                    [age.append(i) for i in [stats[1]]*len(distances)]
                    [distance.append(i) for i in distances]

                    fgm_list = [stats[2],stats[5],stats[8],stats[11],stats[14],stats[17]]
                    fga_list = [stats[3],stats[6],stats[9],stats[12],stats[15],stats[18]]
                    [fgm.append(i) for i in fgm_list]
                    [fga.append(i) for i in fga_list]

            #Create new_df and append to df_all
            new_df = pd.DataFrame({'Player':player,
                        'Team':team,
                        'Age':age,
                        'Distance':distance,
                        'FGM':fgm,
                        'FGA':fga})
            new_df['Game_Date'] = full_date
            df_all = df_all.append(new_df,ignore_index = True)
            print("Done scraping",full_date,"\n")
            driver.close()
            time.sleep(3)

        return df_all

# endregion

# region Using the Scraper
start = date(2018,10,16)
end = date(2019,4,11)
szn = "Regular"
season = 2018

stats_range = nba_stats(start,end,season,szn)
#df = stats_range.opponent_shooting()
#df3 = stats_range.defensive_dashboard(shot_category = '3pt') #test dataset
#endregion

#region Date Cleanup
# Some dates are missed because the browser doesn't load in time
# This won't really be an issue going forward if we're scraping one day at a time
all_dates = [pd.to_datetime(i) for i in stats_range.daterange(stats_range.start_date, stats_range.end_date)]
dates_scraped = list(df['Game_Date'].unique())
datetime_list = list(pd.to_datetime(dates_scraped))
not_scraped = list(set(all_dates) - set(datetime_list))
date_cleanup = nba_stats(start,end,season,szn,date_list=not_scraped)
df_cleanup = date_cleanup.opponent_shooting()
#endregion

# region Joining to GameLogs
# Opponent Shooting Prep
opponent_shooting = pd.read_csv('opponent_shooting.csv')
opponent_shooting.info()
category_cols = ['Player','Team','Distance','Season']
opponent_shooting[category_cols] = opponent_shooting[category_cols].astype('category')
opponent_shooting['Game_Date'] = pd.to_datetime(opponent_shooting['Game_Date'])
opponent_shooting.info()

#Game log Prep
game_logs = pd.read_csv('game_logs.csv')
subset_cols = [
    "dateGame","idGame","numberGameTeamSeason","nameTeam",
    "idTeam","isB2B","isB2BFirst","isB2BSecond","locationGame",
    "slugMatchup","slugTeam","countDaysRestTeam","countDaysNextGameTeam",
    "slugOpponent","slugTeamWinner","slugTeamLoser","outcomeGame","namePlayer",
    "numberGamePlayerSeason","countDaysRestPlayer","countDaysNextGamePlayer","idPlayer",
    "isWin","fgm","fga","fg3m","fg3a","fg2m","fg2a","minutes","ftm","fta","oreb","dreb",
    "treb","ast","stl","blk","tov","pf","pts","plusminus","urlTeamSeasonLogo","urlPlayerStats",
    "urlPlayerThumbnail","urlPlayerHeadshot","urlPlayerActionPhoto","urlPlayerPhoto"
]
game_logs = game_logs[subset_cols]
category_cols = ["namePlayer","nameTeam"]
game_logs[category_cols] = game_logs[category_cols].astype('category')
game_logs['dateGame'] = pd.to_datetime(game_logs['dateGame'])

#Join
all_data = opponent_shooting.merge(game_logs, how = 'left',
                        left_on = ['Player', 'Game_Date'],
                        right_on = ['namePlayer', 'dateGame']).rename(columns = {'FGM':'DFGM','FGA':'DFGA'})
all_data.drop(labels = ['dateGame','slugTeam','namePlayer'], axis = 1, inplace = True)
all_data.to_csv('FinalGameLogs.csv', index = False)