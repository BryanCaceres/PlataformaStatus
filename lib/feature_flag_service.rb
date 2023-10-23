class FeatureFlagService
    
    def self.is_active?(name)
        FeatureFlag.find_by(name: name).try(:is_active) || false
	end
    
end
