alias Koturna.Repo
alias Koturna.Identity.{Organization, User, OrganizationMembership}
alias Koturna.Properties.{Building, Floor, Unit, Asset, InventoryItem}
alias Koturna.Maintenance.Vendor
alias Koturna.Inspections.{InspectionSession, InspectionCheckpoint, Observation}
alias Koturna.Maintenance.MaintenanceTicket

import Ecto.Query

# ── Truncate existing data (bottom-up for FK order) ──────────
Repo.delete_all(MaintenanceTicket)
Repo.delete_all(Observation)
Repo.delete_all(InspectionCheckpoint)
Repo.delete_all(InspectionSession)
Repo.delete_all(Vendor)
Repo.delete_all(InventoryItem)
Repo.delete_all(Asset)
Repo.delete_all(Unit)
Repo.delete_all(Floor)
Repo.delete_all(Building)
Repo.delete_all(OrganizationMembership)
Repo.delete_all(User)
Repo.delete_all(Organization)

# ── Organization ──────────────────────────────────────────────
{:ok, org} =
  %Organization{}
  |> Organization.changeset(%{
    name: "Sunset Properties",
    slug: "sunset-properties",
    timezone: "America/Los_Angeles"
  })
  |> Repo.insert()

# ── Users ─────────────────────────────────────────────────────
users_data = [
  %{
    email: "alice@sunsetproperties.com",
    full_name: "Alice Chen",
    role: "owner",
    password: "password123"
  },
  %{
    email: "bob@sunsetproperties.com",
    full_name: "Bob Martinez",
    role: "manager",
    password: "password123"
  },
  %{
    email: "carol@sunsetproperties.com",
    full_name: "Carol Inspector",
    role: "inspector",
    password: "password123"
  }
]

users =
  Enum.map(users_data, fn data ->
    {:ok, user} =
      %User{}
      |> User.registration_changeset(%{
        email: data.email,
        full_name: data.full_name,
        password: data.password
      })
      |> Repo.insert()

    {:ok, _membership} =
      %OrganizationMembership{}
      |> OrganizationMembership.changeset(%{
        user_id: user.id,
        organization_id: org.id,
        role: data.role
      })
      |> Repo.insert()

    user
  end)

[alice, bob, carol] = users

# ── Buildings ─────────────────────────────────────────────────
{:ok, building_a} =
  %Building{}
  |> Building.changeset(%{
    name: "Oceanview Heights",
    address: "1200 Pacific Coast Hwy",
    city: "Santa Monica",
    country: "US",
    latitude: Decimal.new("34.0195000"),
    longitude: Decimal.new("-118.4912000"),
    total_floors: 3,
    total_units: 6,
    organization_id: org.id
  })
  |> Repo.insert()

{:ok, building_b} =
  %Building{}
  |> Building.changeset(%{
    name: "Marina Towers",
    address: "4500 Admiralty Way",
    city: "Marina del Rey",
    country: "US",
    latitude: Decimal.new("33.9806000"),
    longitude: Decimal.new("-118.4514000"),
    total_floors: 2,
    total_units: 4,
    organization_id: org.id
  })
  |> Repo.insert()

# ── Floors ────────────────────────────────────────────────────
floors_a =
  for n <- 1..3 do
    {:ok, floor} =
      %Floor{}
      |> Floor.changeset(%{
        building_id: building_a.id,
        number: n,
        label: "Floor #{n}"
      })
      |> Repo.insert()

    floor
  end

floors_b =
  for n <- 1..2 do
    {:ok, floor} =
      %Floor{}
      |> Floor.changeset(%{
        building_id: building_b.id,
        number: n,
        label: "Level #{n}"
      })
      |> Repo.insert()

    floor
  end

# ── Units ─────────────────────────────────────────────────────
unit_types = ~w(studio apartment apartment apartment penthouse commercial)

units_a =
  for n <- 1..6 do
    floor_number = div(n - 1, 2) + 1
    unit_index = rem(n - 1, 2) + 1
    floor = Enum.at(floors_a, floor_number - 1)

    {:ok, unit} =
      %Unit{}
      |> Unit.changeset(%{
        building_id: building_a.id,
        floor_id: floor.id,
        unit_number: "#{floor_number}0#{unit_index}",
        unit_type: Enum.at(unit_types, n - 1),
        bedrooms: Enum.random(0..2),
        bathrooms: Enum.random(1..2),
        square_meters: Decimal.new(to_string(Enum.random(35..120))),
        occupancy_status: Enum.random(~w(vacant occupied vacant vacant))
      })
      |> Repo.insert()

    unit
  end

units_b =
  for n <- 1..4 do
    floor_number = div(n - 1, 2) + 1
    unit_index = rem(n - 1, 2) + 1
    floor = Enum.at(floors_b, floor_number - 1)

    {:ok, unit} =
      %Unit{}
      |> Unit.changeset(%{
        building_id: building_b.id,
        floor_id: floor.id,
        unit_number: "#{floor_number}0#{unit_index}",
        unit_type: Enum.random(~w(studio apartment penthouse)),
        bedrooms: Enum.random(0..2),
        bathrooms: Enum.random(1..2),
        square_meters: Decimal.new(to_string(Enum.random(40..150))),
        occupancy_status: Enum.random(~w(vacant occupied vacant))
      })
      |> Repo.insert()

    unit
  end

all_units = units_a ++ units_b

# ── Assets ────────────────────────────────────────────────────
asset_templates = [
  %{category: "ac", name: "Split AC Unit", manufacturer: "Daikin"},
  %{category: "ac", name: "Window AC Unit", manufacturer: "LG"},
  %{category: "appliance", name: "Refrigerator", manufacturer: "Samsung"},
  %{category: "appliance", name: "Dishwasher", manufacturer: "Bosch"},
  %{category: "appliance", name: "Washing Machine", manufacturer: "LG"},
  %{category: "appliance", name: "Microwave", manufacturer: "Panasonic"},
  %{category: "furniture", name: "Sofa", manufacturer: "IKEA"},
  %{category: "furniture", name: "Bed Frame", manufacturer: "West Elm"},
  %{category: "plant", name: "Fiddle Leaf Fig", manufacturer: nil},
  %{category: "plant", name: "Monstera", manufacturer: nil},
  %{category: "fixture", name: "Ceiling Fan", manufacturer: "Hunter"},
  %{category: "fixture", name: "LED Light Panel", manufacturer: "Philips"},
  %{category: "safety", name: "Smoke Detector", manufacturer: "Nest"},
  %{category: "safety", name: "CO Detector", manufacturer: "First Alert"},
  %{category: "safety", name: "Fire Extinguisher", manufacturer: "Kidde"},
  %{category: "appliance", name: "Coffee Maker", manufacturer: "Keurig"},
  %{category: "appliance", name: "Toaster", manufacturer: "Cuisinart"},
  %{category: "fixture", name: "Water Heater", manufacturer: "Rheem"},
  %{category: "furniture", name: "Dining Table", manufacturer: "CB2"},
  %{category: "safety", name: "First Aid Kit", manufacturer: nil}
]

assets =
  asset_templates
  |> Enum.with_index(1)
  |> Enum.map(fn {template, idx} ->
    unit = Enum.at(all_units, rem(idx, length(all_units)))

    {:ok, asset} =
      %Asset{}
      |> Asset.changeset(%{
        unit_id: unit.id,
        category: template.category,
        name: template.name,
        manufacturer: template.manufacturer,
        serial_number: "SN-#{:crypto.strong_rand_bytes(4) |> Base.encode16()}",
        installed_at: ~U[2023-06-01 00:00:00Z],
        expected_lifespan_months: Enum.random(36..120)
      })
      |> Repo.insert()

    asset
  end)

# ── Inventory Items ───────────────────────────────────────────
inventory_items_data = [
  %{sku: "TOWEL-WHT-001", name: "White Bath Towel", quantity: 4},
  %{sku: "TOWEL-BCH-001", name: "Beach Towel", quantity: 2},
  %{sku: "SHEET-QN-001", name: "Queen Sheet Set", quantity: 3},
  %{sku: "PILLOW-001", name: "Standard Pillow", quantity: 4},
  %{sku: "CUTLERY-001", name: "Cutlery Set (24pc)", quantity: 1},
  %{sku: "PLATE-001", name: "Dinner Plate Set (6pc)", quantity: 2},
  %{sku: "GLASS-001", name: "Wine Glass Set (4pc)", quantity: 2},
  %{sku: "PAN-001", name: "Non-stick Frying Pan", quantity: 2}
]

inventory_items =
  inventory_items_data
  |> Enum.with_index(1)
  |> Enum.map(fn {data, idx} ->
    unit = Enum.at(all_units, rem(idx, length(all_units)))

    {:ok, item} =
      %InventoryItem{}
      |> InventoryItem.changeset(%{
        unit_id: unit.id,
        sku: data.sku,
        name: data.name,
        expected_quantity: data.quantity
      })
      |> Repo.insert()

    item
  end)

# ── Vendors ───────────────────────────────────────────────────
vendor_data = [
  %{
    company_name: "Coastal Plumbing",
    service_category: "plumbing",
    contact_name: "Mike Taylor",
    phone: "310-555-0101",
    email: "mike@coastalplumbing.com"
  },
  %{
    company_name: "Westside Electric",
    service_category: "electrical",
    contact_name: "Sarah Kim",
    phone: "310-555-0102",
    email: "sarah@westsideelectric.com"
  },
  %{
    company_name: "Cool Breeze HVAC",
    service_category: "hvac",
    contact_name: "James Wilson",
    phone: "310-555-0103",
    email: "james@coolbreezehvac.com"
  },
  %{
    company_name: "LA Handyman Services",
    service_category: "general",
    contact_name: "David Garcia",
    phone: "310-555-0104",
    email: "david@lahandyman.com"
  },
  %{
    company_name: "Green Clean Co",
    service_category: "cleaning",
    contact_name: "Emily Park",
    phone: "310-555-0105",
    email: "emily@greencleanco.com"
  }
]

vendors =
  Enum.map(vendor_data, fn data ->
    {:ok, vendor} =
      %Vendor{}
      |> Vendor.changeset(%{
        organization_id: org.id,
        company_name: data.company_name,
        service_category: data.service_category,
        contact_name: data.contact_name,
        phone: data.phone,
        email: data.email
      })
      |> Repo.insert()

    vendor
  end)

# ── Inspection Sessions ───────────────────────────────────────
# Completed inspection 1
{:ok, session1} =
  %InspectionSession{}
  |> InspectionSession.changeset(%{
    organization_id: org.id,
    building_id: building_a.id,
    unit_id: units_a |> Enum.at(0) |> then(& &1.id),
    inspector_user_id: carol.id,
    inspection_type: "checkout",
    status: "completed",
    started_at: ~U[2024-06-15 09:00:00Z],
    completed_at: ~U[2024-06-15 09:45:00Z]
  })
  |> Repo.insert()

# Completed inspection 2
{:ok, session2} =
  %InspectionSession{}
  |> InspectionSession.changeset(%{
    organization_id: org.id,
    building_id: building_a.id,
    unit_id: units_a |> Enum.at(2) |> then(& &1.id),
    inspector_user_id: carol.id,
    inspection_type: "maintenance",
    status: "completed",
    started_at: ~U[2024-06-16 10:00:00Z],
    completed_at: ~U[2024-06-16 10:30:00Z]
  })
  |> Repo.insert()

# In-progress inspection 3
{:ok, session3} =
  %InspectionSession{}
  |> InspectionSession.changeset(%{
    organization_id: org.id,
    building_id: building_b.id,
    unit_id: units_b |> Enum.at(1) |> then(& &1.id),
    inspector_user_id: carol.id,
    inspection_type: "checkout",
    status: "in_progress",
    started_at: ~U[2024-06-17 14:00:00Z]
  })
  |> Repo.insert()

# ── Checkpoints ───────────────────────────────────────────────
checkpoint_templates = [
  %{code: "AC-01", label: "Check AC filter condition", required: true},
  %{code: "AC-02", label: "Test thermostat function", required: true},
  %{code: "PLUMB-01", label: "Inspect under-sink plumbing", required: true},
  %{code: "PLUMB-02", label: "Check for toilet leaks", required: true},
  %{code: "ELEC-01", label: "Test all outlets", required: false},
  %{code: "SAFE-01", label: "Verify smoke detector operation", required: true},
  %{code: "SAFE-02", label: "Check fire extinguisher gauge", required: true},
  %{code: "CLN-01", label: "Inspect general cleanliness", required: true},
  %{code: "INV-01", label: "Verify inventory count", required: false},
  %{code: "STRUC-01", label: "Check walls for cracks", required: true},
  %{code: "STRUC-02", label: "Check ceiling for water stains", required: true},
  %{code: "PLANT-01", label: "Assess plant health", required: false}
]

for session <- [session1, session2] do
  checkpoint_templates
  |> Enum.map(fn tmpl ->
    {:ok, cp} =
      %InspectionCheckpoint{}
      |> InspectionCheckpoint.changeset(%{
        inspection_session_id: session.id,
        code: tmpl.code,
        label: tmpl.label,
        required: tmpl.required,
        completed_at: if(session.status == "completed", do: ~U[2024-06-15 09:30:00Z], else: nil)
      })
      |> Repo.insert()

    cp
  end)
end

# ── Observations ──────────────────────────────────────────────
observations_data = [
  # Session 1 observations
  %{
    inspection_session_id: session1.id,
    observation_type: "ac_condition",
    severity: "info",
    confidence: 0.95,
    location_label: "Living Room",
    summary: "AC filter clean, replaced 2 weeks ago"
  },
  %{
    inspection_session_id: session1.id,
    observation_type: "cleaning",
    severity: "low",
    confidence: 0.85,
    location_label: "Kitchen",
    summary: "Minor dust on top of cabinets"
  },
  %{
    inspection_session_id: session1.id,
    observation_type: "plant_health",
    severity: "medium",
    confidence: 0.70,
    location_label: "Balcony",
    summary: "Fiddle leaf fig showing browning leaf edges — possible underwatering"
  },
  %{
    inspection_session_id: session1.id,
    observation_type: "safety",
    severity: "low",
    confidence: 0.90,
    location_label: "Hallway",
    summary: "Loose handrail on staircase"
  },
  %{
    inspection_session_id: session1.id,
    observation_type: "leak_risk",
    severity: "critical",
    confidence: 0.95,
    location_label: "Bathroom",
    summary: "Active leak under bathroom sink — water pooling on cabinet floor"
  },
  %{
    inspection_session_id: session1.id,
    observation_type: "damage",
    severity: "high",
    confidence: 0.88,
    location_label: "Living Room",
    summary: "Drywall crack near window frame, approx 30cm"
  },
  # Session 2 observations
  %{
    inspection_session_id: session2.id,
    observation_type: "ac_condition",
    severity: "high",
    confidence: 0.92,
    location_label: "Bedroom",
    summary: "AC unit not cooling properly — temperature differential only 3°C"
  },
  %{
    inspection_session_id: session2.id,
    observation_type: "damage",
    severity: "medium",
    confidence: 0.80,
    location_label: "Kitchen",
    summary: "Cabinet door hinge loose, risks falling off"
  },
  %{
    inspection_session_id: session2.id,
    observation_type: "inventory",
    severity: "low",
    confidence: 0.95,
    location_label: "Kitchen",
    summary: "Missing 1 dinner plate from set"
  },
  %{
    inspection_session_id: session2.id,
    observation_type: "leak_risk",
    severity: "medium",
    confidence: 0.78,
    location_label: "Bathroom",
    summary: "Minor grout cracking in shower — moisture risk"
  }
]

observations =
  Enum.map(observations_data, fn data ->
    {:ok, obs} =
      %Observation{}
      |> Observation.changeset(data)
      |> Repo.insert()

    obs
  end)

# ── Maintenance Tickets ───────────────────────────────────────
# Ticket from critical leak observation
critical_leak = Enum.find(observations, &(&1.severity == "critical"))

if critical_leak do
  {:ok, _ticket1} =
    %MaintenanceTicket{}
    |> MaintenanceTicket.changeset(%{
      organization_id: org.id,
      building_id: building_a.id,
      unit_id: units_a |> Enum.at(0) |> then(& &1.id),
      source_observation_id: critical_leak.id,
      title: "Emergency: Active water leak under bathroom sink",
      description: critical_leak.summary,
      priority: "urgent",
      status: "assigned",
      estimated_cost_cents: 50_000,
      assigned_vendor_id: vendors |> Enum.at(0) |> then(& &1.id)
    })
    |> Repo.insert()
end

# Ticket from AC issue
ac_observation =
  Enum.find(observations, &(&1.severity == "high" and &1.observation_type == "ac_condition"))

if ac_observation do
  {:ok, _ticket2} =
    %MaintenanceTicket{}
    |> MaintenanceTicket.changeset(%{
      organization_id: org.id,
      building_id: building_a.id,
      unit_id: units_a |> Enum.at(2) |> then(& &1.id),
      source_observation_id: ac_observation.id,
      title: "AC not cooling properly — service call needed",
      description: ac_observation.summary,
      priority: "high",
      status: "open",
      estimated_cost_cents: 35_000,
      assigned_vendor_id: vendors |> Enum.at(2) |> then(& &1.id)
    })
    |> Repo.insert()
end

# Manual ticket (no observation)
{:ok, _ticket3} =
  %MaintenanceTicket{}
  |> MaintenanceTicket.changeset(%{
    organization_id: org.id,
    building_id: building_b.id,
    unit_id: units_b |> Enum.at(0) |> then(& &1.id),
    title: "Replace broken window lock — guest reported",
    description: "Window lock in Unit 101 bedroom is jammed. Guest request.",
    priority: "medium",
    status: "open",
    estimated_cost_cents: 15_000
  })
  |> Repo.insert()

# ── Summary ────────────────────────────────────────────────────
IO.puts("""

Seeds complete!

  Organization:  #{org.name}
  Users:         #{length(users)}
  Buildings:     #{2}
  Units:         #{length(all_units)}
  Assets:        #{length(assets)}
  Inventory:     #{length(inventory_items)}
  Vendors:       #{length(vendors)}
  Inspections:   #{3} (2 completed, 1 in progress)
  Observations:  #{length(observations)}
  Tickets:       #{3}
""")
