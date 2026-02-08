class PropertyFetcher
  # Average rent prices per sqm by district (2025/2026 estimates)
  DISTRICT_RENT_AVERAGES = {
    'Mitte' => 16.50,
    'Friedrichshain-Kreuzberg' => 15.80,
    'Pankow' => 13.20,
    'Charlottenburg-Wilmersdorf' => 14.90,
    'Spandau' => 10.50,
    'Steglitz-Zehlendorf' => 12.80,
    'Tempelhof-Schöneberg' => 13.50,
    'Neukölln' => 12.90,
    'Treptow-Köpenick' => 11.80,
    'Marzahn-Hellersdorf' => 9.50,
    'Lichtenberg' => 11.20,
    'Reinickendorf' => 10.80
  }.freeze

  PROPERTY_TYPES = %w[Wohnung Altbau Neubau Penthouse Loft Maisonette Dachgeschoss Erdgeschoss].freeze
  HEATING_TYPES = %w[Zentralheizung Fernwärme Gasheizung Ölheizung Fußbodenheizung Wärmepumpe].freeze
  CONDITIONS = %w[Erstbezug Neuwertig Gepflegt Renovierungsbedürftig].freeze
  ENERGY_RATINGS = %w[A+ A B C D E F G H].freeze

  def self.fetch_all
    new.fetch
  end

  def fetch
    generate_realistic_listings
  end

  private

  def generate_realistic_listings
    listings = []
    count = rand(25..45)

    count.times do
      district = Property::BERLIN_DISTRICTS.sample
      neighborhoods = Property::POPULAR_NEIGHBORHOODS[district] || [district]
      neighborhood = neighborhoods.sample

      rooms = weighted_random_rooms
      living_space = realistic_living_space(rooms)
      base_price_sqm = DISTRICT_RENT_AVERAGES[district] || 12.0
      price_sqm = vary_price(base_price_sqm)
      price = (living_space * price_sqm).round(2)
      additional = (living_space * rand(2.5..4.5)).round(2)
      heating = (living_space * rand(1.0..2.0)).round(2)

      construction_year = weighted_construction_year
      floor = rand(0..6)
      total_floors = floor + rand(0..4)

      listings << {
        external_id: "BPS-#{SecureRandom.hex(6)}",
        source: ['immobilienscout24', 'immowelt', 'ebay-kleinanzeigen', 'wg-gesucht', 'immonet'].sample,
        title: generate_title(rooms, neighborhood, living_space),
        description: generate_description(rooms, neighborhood, living_space, district),
        property_type: PROPERTY_TYPES.sample,
        offer_type: 'rent',
        price: price,
        price_per_sqm: price_sqm,
        additional_costs: additional,
        heating_costs: heating,
        total_rent: price + additional + heating,
        deposit: (price * rand(2..3)).round(2),
        living_space: living_space,
        rooms: rooms,
        floor: floor,
        total_floors: total_floors,
        district: district,
        neighborhood: neighborhood,
        address: generate_address(neighborhood),
        zip_code: generate_zip_code(district),
        latitude: 52.52 + rand(-0.15..0.15),
        longitude: 13.405 + rand(-0.2..0.2),
        balcony: rand < 0.55,
        garden: rand < 0.15,
        elevator: rand < (total_floors > 3 ? 0.7 : 0.25),
        cellar: rand < 0.65,
        parking: rand < 0.2,
        furnished: rand < 0.1,
        pets_allowed: rand < 0.35,
        energy_rating: ENERGY_RATINGS.sample,
        construction_year: construction_year,
        heating_type: HEATING_TYPES.sample,
        condition: CONDITIONS.sample,
        available_from: Date.today + rand(1..90).days,
        wbs_required: rand < 0.15,
        url: "#",
        image_url: nil,
        contact_name: generate_contact_name,
        contact_phone: generate_phone,
        listed_at: Time.current - rand(0..72).hours
      }
    end

    listings
  end

  def weighted_random_rooms
    roll = rand(100)
    return 1 if roll < 15
    return 2 if roll < 50
    return 3 if roll < 80
    return 4 if roll < 93
    5
  end

  def realistic_living_space(rooms)
    base = case rooms
           when 1 then rand(25..45)
           when 2 then rand(40..70)
           when 3 then rand(60..95)
           when 4 then rand(80..120)
           else rand(100..150)
           end
    base + rand(-5.0..5.0).round(1)
  end

  def vary_price(base)
    variation = base * rand(-0.25..0.35)
    (base + variation).round(2)
  end

  def weighted_construction_year
    roll = rand(100)
    return rand(1890..1930) if roll < 30  # Altbau
    return rand(1950..1980) if roll < 55  # Nachkrieg
    return rand(1990..2010) if roll < 80  # Modern
    rand(2015..2025)                       # Neubau
  end

  STREET_NAMES = [
    'Kastanienallee', 'Oranienstraße', 'Bergmannstraße', 'Schönhauser Allee',
    'Karl-Marx-Allee', 'Kurfürstendamm', 'Friedrichstraße', 'Torstraße',
    'Greifswalder Straße', 'Prenzlauer Allee', 'Sonnenallee', 'Hermannstraße',
    'Kantstraße', 'Bismarckstraße', 'Turmstraße', 'Müllerstraße',
    'Danziger Straße', 'Warschauer Straße', 'Frankfurter Allee', 'Landsberger Allee',
    'Bornholmer Straße', 'Stargarder Straße', 'Wisbyer Straße', 'Pappelallee',
    'Kollwitzstraße', 'Helmholtzplatz', 'Maybachufer', 'Weserstraße',
    'Reuterstraße', 'Pannierstraße', 'Richardstraße', 'Flughafenstraße'
  ].freeze

  FIRST_NAMES = %w[Schmidt Müller Weber Fischer Meyer Wagner Becker Schulz Hoffmann Koch].freeze

  def generate_address(neighborhood)
    "#{STREET_NAMES.sample} #{rand(1..200)}, #{neighborhood}"
  end

  def generate_zip_code(district)
    prefix = case district
             when 'Mitte' then '101'
             when 'Friedrichshain-Kreuzberg' then '102'
             when 'Pankow' then '104'
             when 'Charlottenburg-Wilmersdorf' then '107'
             when 'Spandau' then '136'
             when 'Steglitz-Zehlendorf' then '121'
             when 'Tempelhof-Schöneberg' then '108'
             when 'Neukölln' then '120'
             when 'Treptow-Köpenick' then '125'
             when 'Marzahn-Hellersdorf' then '126'
             when 'Lichtenberg' then '130'
             when 'Reinickendorf' then '134'
             else '100'
             end
    "#{prefix}#{rand(10..99)}"
  end

  def generate_title(rooms, neighborhood, space)
    templates = [
      "Schöne #{rooms}-Zimmer-Wohnung in #{neighborhood}",
      "#{rooms} Zi. | #{space.round(0)}m² | #{neighborhood}",
      "Helle #{rooms}-Raum-Wohnung, #{neighborhood}",
      "Bezugsfertige #{rooms}-Zimmer-Whg. in #{neighborhood}",
      "#{neighborhood}: #{rooms} Zimmer, #{space.round(0)}m²",
      "Traumhafte #{rooms}-Zi.-Wohnung #{neighborhood}",
      "Gepflegte #{rooms}-Zimmer-Wohnung nahe #{neighborhood}"
    ]
    templates.sample
  end

  def generate_description(rooms, neighborhood, space, district)
    "#{rooms}-Zimmer-Wohnung mit ca. #{space.round(0)}m² Wohnfläche " \
    "in beliebter Lage von #{neighborhood} (#{district}). " \
    "Die Wohnung verfügt über einen hellen Grundriss und ist gut geschnitten."
  end

  def generate_contact_name
    "Hausverwaltung #{FIRST_NAMES.sample} & Partner"
  end

  def generate_phone
    "030 #{rand(1000..9999)} #{rand(1000..9999)}"
  end
end
