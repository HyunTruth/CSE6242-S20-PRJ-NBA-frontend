court_themes = list(
  light = list(
    court = '#FFFFFF',
    lines = '#999999',
    text = '#222222'
  ),
  dark = list(
    court = '#000004',
    lines = '#999999',
    text = '#f0f0f0'
  )
)


circle_points = function(center = c(0, 0), radius = 1, npoints = 360) {
  angles = seq(0, 2 * pi, length.out = npoints)
  return(tibble(x = center[1] + radius * cos(angles),
                y = center[2] + radius * sin(angles)))
}

width = 50
height = 94 / 2
key_height = 19
inner_key_width = 12
outer_key_width = 16
backboard_width = 8
backboard_offset = 4
neck_length = 0.5
hoop_radius = 0.75
hoop_center_y = backboard_offset + neck_length + hoop_radius
three_point_radius = 23.75
three_point_side_radius = 22
three_point_side_height = 14

plot_court = function(court_theme = court_themes$light, use_short_three = FALSE) {
  if (use_short_three) {
    three_point_radius = 22
    three_point_side_height = 0
  }
  
  court_points = tibble(
    x = c(width / 2, width / 2, -width / 2, -width / 2, width / 2),
    y = c(height, 0, 0, height, height),
    desc = "perimeter"
  )
  
  court_points = bind_rows(court_points , tibble(
    x = c(outer_key_width / 2, outer_key_width / 2, -outer_key_width / 2, -outer_key_width / 2),
    y = c(0, key_height, key_height, 0),
    desc = "outer_key"
  ))
  
  court_points = bind_rows(court_points , tibble(
    x = c(-backboard_width / 2, backboard_width / 2),
    y = c(backboard_offset, backboard_offset),
    desc = "backboard"
  ))
  
  court_points = bind_rows(court_points , tibble(
    x = c(0, 0), y = c(backboard_offset, backboard_offset + neck_length), desc = "neck"
  ))
  
  foul_circle = circle_points(center = c(0, key_height), radius = inner_key_width / 2)
  
  foul_circle_top = filter(foul_circle, y > key_height) %>%
    mutate(desc = "foul_circle_top")
  
  foul_circle_bottom = filter(foul_circle, y < key_height) %>%
    mutate(
      angle = atan((y - key_height) / x) * 180 / pi,
      angle_group = floor((angle - 5.625) / 11.25),
      desc = paste0("foul_circle_bottom_", angle_group)
    ) %>%
    filter(angle_group %% 2 == 0) %>%
    select(x, y, desc)
  
  hoop = circle_points(center = c(0, hoop_center_y), radius = hoop_radius) %>%
    mutate(desc = "hoop")
  
  restricted = circle_points(center = c(0, hoop_center_y), radius = 4) %>%
    filter(y >= hoop_center_y) %>%
    mutate(desc = "restricted")
  
  three_point_circle = circle_points(center = c(0, hoop_center_y), radius = three_point_radius) %>%
    filter(y >= three_point_side_height, y >= hoop_center_y)
  
  three_point_line = tibble(
    x = c(three_point_side_radius, three_point_side_radius, three_point_circle$x, -three_point_side_radius, -three_point_side_radius),
    y = c(0, three_point_side_height, three_point_circle$y, three_point_side_height, 0),
    desc = "three_point_line"
  )
  
  ### 0-9 ft Line ###
  zero_nine_line = circle_points(center = c(0, hoop_center_y), radius = 10) %>%
    filter(y > 0) %>%
    mutate(desc = "zero_nine_line")

  ### 10-19 ft Line ###
  ten_nineteen_line = circle_points(center = c(0, hoop_center_y), radius = 20) %>%
    filter(y > 0) %>%
    mutate(desc = "ten_nineteen_line")
  
  ### 20-24 ft Line ###
  twenty_twentyfour_line = circle_points(center = c(0, hoop_center_y), radius = 24) %>%
    filter(y > 0) %>%
    mutate(desc = "twenty_twentyfour")
  
  twentyfour_twentynine_line = circle_points(center = c(0, hoop_center_y), radius = 29) %>%
    filter(y > 0, x > -width / 2, x < width /2) %>%
    mutate(desc = "twentyfour_twentynine")

  court_points = bind_rows(
    court_points,
    foul_circle_top,
    #foul_circle_bottom,
    hoop,
    restricted,
    zero_nine_line,
    ten_nineteen_line,
    twenty_twentyfour_line,
    twentyfour_twentynine_line
  )
  
  court_points <<- court_points
  
  annotation <- data.frame(
    x = c(0,0,0,0),
    y = c(10,19,27,32),
    label = c("55.3%", "47.2%","41.6%","35.1%")
  )
  
  ggplot() +
    geom_ribbon(data = court_points,
                aes(ymin = 0, ymax = 47, x = x), fill = "#FFFFFF", alpha = .7) +
    geom_ribbon(data = court_points %>% filter(desc == "twentyfour_twentynine"),
                aes(ymin = 0, ymax = y, x = x), fill = "#92c5de", alpha = .7) +
    geom_ribbon(data = court_points %>% filter(desc == "twenty_twentyfour"),
                aes(ymin = 0, ymax = y, x = x), fill = "#fddbc7", alpha = .7) +
    geom_ribbon(data = court_points %>% filter(desc == "ten_nineteen_line"),
                aes(ymin = 0, ymax = y, x = x), fill = "#f4a582", alpha = .7) +
    geom_ribbon(data = court_points %>% filter(desc == "zero_nine_line"),
                aes(ymin = 0, ymax = y, x = x), fill = "#0571b0", alpha = .7) +
    geom_path(
      data = court_points,
      aes(x = x, y = y, group = desc),
      color = court_theme$lines
    ) +
    geom_label(data=annotation, aes(x = x,y = y, label=label),
              color="#4d4d4d", 
              size= 5 , angle=0, fontface="bold" ) +
    coord_fixed(ylim = c(0, 35), xlim = c(-25, 25)) +
    theme_minimal(base_size = 22) +
    theme(
      text = element_text(color = court_theme$text),
      plot.background = element_rect(fill = court_theme$court, color = court_theme$court),
      panel.background = element_rect(fill = court_theme$court, color = court_theme$court),
      panel.grid = element_blank(),
      panel.border = element_blank(),
      axis.text = element_blank(),
      axis.title = element_blank(),
      axis.ticks = element_blank(),
      legend.background = element_rect(fill = court_theme$court, color = court_theme$court),
      legend.margin = margin(-1, 0, 0, 0, unit = "lines"),
      legend.position = "bottom",
      legend.key = element_blank(),
      legend.text = element_text(size = rel(1.0))
    )
}
